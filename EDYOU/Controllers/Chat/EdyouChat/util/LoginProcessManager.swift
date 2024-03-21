    //
    //  LoginProcessManager.swift
    //  Edyou IM
    //
    //  Created by Suleman Ali on 09/01/2024.
    //  Copyright © 2024 Tigase, Inc. All rights reserved.
    //

import Foundation
import UIKit
import Martin
import Combine
import Shared

class LoginProcessManager {
    var accountValidatorTask: AccountValidatorTask?;
    private var id = "faisal@ejabberd.edyou.io"
    private var pass = "faisal"
    private var port:Int? = 0
    private var host:String? = ""
    var completionHandler:((Bool,Error?)->Void) = {_,_ in }
    private var useDirectTLS:Bool = false
    private var disableTLS13:Bool =  false

    init(id:String,pass:String,port:Int?,host:String?, useDirectTLS:Bool = false, disableTLS13:Bool = false,completion: @escaping ((Bool,Error?)->Void)) {
        self.id = id
        self.pass = pass
        self.port = port
        self.host = host
        self.useDirectTLS = useDirectTLS
        self.disableTLS13 = disableTLS13
        self.completionHandler = completion
    }

    func loginValidateAccount() {
        let jid = BareJID(id)
        self.accountValidatorTask = AccountValidatorTask();
        self.accountValidatorTask?.check(account: jid, password: pass,host: host,port: port,useDirectTLS: false,disableTLS13: false, callback: self.handleResult);
    }

    func handleResult(result: Result<Void,ErrorCondition>) {
        let acceptedCertificate = accountValidatorTask?.acceptedCertificate;
        self.accountValidatorTask = nil;
        switch result {
            case .failure(let errorCondition):
                completionHandler(false,errorCondition)
            case .success(_):
                self.saveAccount(acceptedCertificate: acceptedCertificate);
        }
    }

    func saveAccount(acceptedCertificate: SslCertificateInfo?) {
        let jid = BareJID(id)
        var account = AccountManager.getAccount(for: jid) ?? AccountManager.Account(name: jid);
        account.acceptCertificate(acceptedCertificate);
        account.password = pass
        if let host = host, let port = port {
            account.endpoint = .init(proto: useDirectTLS ? .XMPPS : .XMPP, host: host, port: port)
        }
        account.disableTLS13 = disableTLS13;
        var cancellables: Set<AnyCancellable> = [];
        do {
            try AccountManager.save(account: account);
            completionHandler(true,nil)
        } catch let error {
            cancellables.removeAll();
            completionHandler(false,error)
        }
    }

    class AccountValidatorTask: EventHandler {
        private var cancellables: Set<AnyCancellable> = [];
        var client: XMPPClient? {
            willSet {
                if newValue != nil {
                    newValue?.eventBus.register(handler: self, for: SaslModule.SaslAuthSuccessEvent.TYPE, SaslModule.SaslAuthFailedEvent.TYPE);
                }
            }
            didSet {
                cancellables.removeAll();
                if oldValue != nil {
                    _ = oldValue?.disconnect(true);
                    oldValue?.eventBus.unregister(handler: self, for: SaslModule.SaslAuthSuccessEvent.TYPE, SaslModule.SaslAuthFailedEvent.TYPE);
                }
                client?.$state.sink(receiveValue: { [weak self] state in self?.changedState(state) }).store(in: &cancellables);
            }
        }

        var callback: ((Result<Void,ErrorCondition>)->Void)? = nil;
        weak var controller: UIViewController?;
        var dispatchQueue = DispatchQueue(label: "accountValidatorSync");

        var acceptedCertificate: SslCertificateInfo? = nil;

        init() {
            initClient();
        }

        fileprivate func initClient() {
            self.client = XMPPClient();
            _ = client?.modulesManager.register(StreamFeaturesModule());
            _ = client?.modulesManager.register(SaslModule());
            _ = client?.modulesManager.register(AuthModule());
        }

        public func check(account: BareJID, password: String, host:String?,port:Int?,useDirectTLS:Bool = false,disableTLS13:Bool = false, callback: @escaping (Result<Void,ErrorCondition>)->Void) {
            self.callback = callback;
            client?.connectionConfiguration.useSeeOtherHost = false;
            client?.connectionConfiguration.userJid = account;
            client?.connectionConfiguration.modifyConnectorOptions(type: SocketConnectorNetwork.Options.self, { options in
                if let host = host, let port = port {
                    options.connectionDetails = .init(proto: useDirectTLS ? .XMPPS : .XMPP, host: host, port: port)
                }
                options.networkProcessorProviders.append(disableTLS13 ? SSLProcessorProvider(supportedTlsVersions: TLSVersion.TLSv1_2...TLSVersion.TLSv1_2) : SSLProcessorProvider());
            })
            client?.connectionConfiguration.credentials = .password(password: password, authenticationName: nil, cache: nil);
            client?.login();
        }

        public func handle(event: Martin.Event) {
            dispatchQueue.sync {
                guard let callback = self.callback else {
                    return;
                }
                var param: ErrorCondition? = nil;
                switch event {
                    case is SaslModule.SaslAuthSuccessEvent:
                        param = nil;
                    case is SaslModule.SaslAuthFailedEvent:
                        param = ErrorCondition.not_authorized;
                    default:
                        param = ErrorCondition.service_unavailable;
                }

                DispatchQueue.main.async {
                    if let error = param {
                        callback(.failure(error));
                    } else {
                        callback(.success(Void()));
                    }
                }
                self.finish();
            }
        }

        func changedState(_ state: XMPPClient.State) {
            print("changedState==> \(state)")
            dispatchQueue.sync {
                guard let callback = self.callback else {
                    return;
                }
                switch state {
                    case .disconnected(let reason):
                        switch reason {
                            case .sslCertError(let trust):
                                self.callback = nil;
                                let certData = SslCertificateInfo(trust: trust);
                                self.acceptedCertificate = certData;
                                self.client?.connectionConfiguration.modifyConnectorOptions(type: SocketConnectorNetwork.Options.self, { options in
                                    options.networkProcessorProviders.append(SSLProcessorProvider());
                                    options.sslCertificateValidation = .fingerprint(certData.details.fingerprintSha1);
                                });
                                self.callback = callback;
                                self.client?.login();
                                return;
                            default:
                                break;
                        }
                        DispatchQueue.main.async {
                            callback(.failure(.service_unavailable));
                        }
                        self.finish();
                    default:
                        break;
                }
            }
        }

        public func finish() {
            self.callback = nil;
            self.client = nil;
            self.controller = nil;
        }
    }
}

