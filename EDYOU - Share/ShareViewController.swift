//
//  ShareViewController.swift
//  EDYOU - Share
//
//  Created by imac3 on 19/12/2023.
//

import UIKit
import Social
import Shared
import Martin
import TigaseSQLite3
import CSQLite
import MobileCoreServices
import Combine
import UniformTypeIdentifiers

extension Query {

    static let selectRosterItems = Query("SELECT ri.account, ri.jid, ri.name, ri.data FROM roster_items ri");
    static let selectAvatars = Query("select ac.account, ac.jid, ac.type, ac.hash FROM avatars_cache ac");

}

enum AvatarType: String {
    case vcardTemp
    case pepUserAvatar
}

struct AvatarKey: Hashable {
    let account: BareJID;
    let jid: BareJID;
    let type: AvatarType;
}

struct RosterItem: Equatable {
    let account: BareJID;
    let jid: BareJID;
    let name: String?;

    var displayName: String {
        return name ?? jid.stringValue;
    }

    var initials: String? {
        let parts = displayName.uppercased().components(separatedBy: CharacterSet.letters.inverted);
        let first = parts.first?.first;
        let last = parts.count > 1 ? parts.last?.first : nil;
        return (last == nil || first == nil) ? (first == nil ? nil : "\(first!)") : "\(first!)\(last!)";
    }
}

struct DBRosterData: Codable, DatabaseConvertibleStringValue {

    let groups: [String];
    let annotations: [RosterItemAnnotation];

}

class ShareViewController: UITableViewController {

    var recipients: [RosterItem] = [];

    var sharedDefaults = UserDefaults(suiteName: "group.TigaseMessenger.Share");
    var avatarCacheUrl: URL?;

    var avatars: [AvatarKey: String] = [:];
    var rosterItems: [RosterItem] = [];

    var imageQuality: ImageQuality {
        if let valueStr = sharedDefaults?.string(forKey: "imageQuality"), let value = ImageQuality(rawValue: valueStr) {
            return value;
        }
        return .medium;
    }

    var videoQuality: VideoQuality {
        if let valueStr = sharedDefaults?.string(forKey: "videoQuality"), let value = VideoQuality(rawValue: valueStr) {
            return value;
        }
        return .medium;
    }

    override func viewDidLoad() {
        super.viewDidLoad();

        self.navigationItem.title = NSLocalizedString("Select recipients", comment: "view title");
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped(_:))), animated: false);
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped(_:))), animated: false)
        self.navigationItem.rightBarButtonItem?.isEnabled = false;

        let dbUrl = Database.mainDatabaseUrl();

        if !FileManager.default.fileExists(atPath: dbUrl.path) {
            let controller = UIAlertController(title: NSLocalizedString("Please launch application from the home screen before continuing.", comment: "alert title"), message: nil, preferredStyle: .alert);
            controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "button label"), style: .destructive, handler: { (action) in
                self.extensionContext?.cancelRequest(withError: ShareError.unknownError);
            }))
            self.present(controller, animated: true, completion: nil);
        }

        let database = try! Database(path: dbUrl.path, flags: SQLITE_OPEN_WAL | SQLITE_OPEN_READONLY);
        let accounts = Set(getActiveAccounts());
        try! database.select(query: .selectAvatars, params: []).forEach({ c in
            guard let account = c.bareJid(for: "account"), let jid = c.bareJid(for: "jid"), let type = AvatarType(rawValue: c.string(for: "type")!), let hash = c.string(for: "hash") else {
                return;
            }

            avatars[.init(account: account, jid: jid, type: type)] = hash;
        })
        rosterItems = try! database.select(query: .selectRosterItems, cached: false, params: []).mapAll({ c -> RosterItem? in
            guard let account = c.bareJid(for: "account"), accounts.contains(account), let jid = c.bareJid(for: "jid") else {
                return nil;
            }

            if let data: DBRosterData = c.object(for: "data") {
                guard data.annotations.isEmpty else {
                    return nil;
                }
            }

            return RosterItem(account: account, jid: jid, name: c.string(for: "name"));
        }).sorted(by: { r1, r2 -> Bool in
            return r1.displayName.lowercased() < r2.displayName.lowercased();
        })

        avatarCacheUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.edyou.shared")!.appendingPathComponent("Library", isDirectory: true).appendingPathComponent("Caches", isDirectory: true).appendingPathComponent("avatars", isDirectory: true);
        for url in try! FileManager.default.contentsOfDirectory(at: FileManager.default.temporaryDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            try? FileManager.default.removeItem(at: url);
        }
    }

    private var alertController: UIAlertController?;

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        if !sharedDefaults!.bool(forKey: "SharingViaHttpUpload") {
            var error = true;
            if let provider = (self.extensionContext!.inputItems.first as? NSExtensionItem)?.attachments?.first {
                error = !provider.hasItemConformingToTypeIdentifier(UTType.url.identifier);
            }
            if error {
                self.showAlert(title: NSLocalizedString("Failure", comment: "alert title"), message: NSLocalizedString("Sharing feature with HTTP upload is disabled within application. To use this feature you need to enable sharing with HTTP upload in application", comment: "alert body"));
            }
        }
    }

    @objc func cancelTapped(_ sender: Any) {
        let error = NSError(domain: "tigase.siskinim", code: 0, userInfo: [:]);
        self.extensionContext?.cancelRequest(withError: error);
    }

    private var cancellables: Set<AnyCancellable> = [];
    private var cancelled = false;
    private var clients: [XMPPClient] = [];

    @objc func doneTapped(_ sender: Any) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false;
        alertController = UIAlertController(title: "", message: nil, preferredStyle: .alert);
        let activityIndicator = UIActivityIndicatorView(style: .medium);
        activityIndicator.startAnimating();
        let label = UILabel(frame: .zero);
        label.text = NSLocalizedString("Preparing…", comment: "operation label");
        let stack = UIStackView(arrangedSubviews: [activityIndicator, label]);
        stack.alignment = .center;
        stack.distribution = .fillProportionally;
        stack.axis = .horizontal;
        stack.translatesAutoresizingMaskIntoConstraints = false;
        stack.spacing = 14;
        alertController?.view.addSubview(stack);
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: alertController!.view.centerXAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: alertController!.view.leadingAnchor, constant: 20),
            stack.topAnchor.constraint(equalTo: alertController!.view.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: alertController!.view.bottomAnchor, constant: -60)
        ])
        alertController?.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "button label"), style: .cancel, handler: { _ in
            self.cancelled = true;
            for client in self.clients {
                _ = client.disconnect();
            }
            DispatchQueue.main.async {
                self.extensionContext?.cancelRequest(withError: ShareError.unknownError);
            }
        }));
        self.present(alertController!, animated: true, completion: nil);

        self.extractAttachments(completionHandler: { result in
            guard !self.cancelled else {
                if case let .success(att) = result, case let .file(url, _) = att {
                    try? FileManager.default.removeItem(at: url);
                }
                return;
            }
            switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.alertController?.dismiss(animated: true, completion: {
                            self.navigationItem.rightBarButtonItem?.isEnabled = true;
                            self.show(error: error);
                        })
                    }
                case .success(let att):
                    DispatchQueue.main.async {
                        label.text = NSLocalizedString("Sending…", comment: "operation label");
                    }
                    self.share(attachment: att, completionHandler: { errors in
                        DispatchQueue.main.async {
                            self.alertController?.dismiss(animated: true, completion: {
                                self.navigationItem.rightBarButtonItem?.isEnabled = true;
                                guard let error = errors.first?.error else {
                                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil);
                                    return;
                                }
                                self.show(error: error);
                            });
                        }
                    });
            }
        })
    }

    private struct ErrorResult {
        let jid: BareJID;
        let error: Error;
    }

    private func share(attachment: Attachment, completionHandler: @escaping ([ErrorResult])->Void) {
        let accounts = Set(recipients.map({ $0.account }));
        let group = DispatchGroup();
        var errors: [ErrorResult] = [];
        clients = accounts.compactMap({ account -> XMPPClient? in
            guard let password = getAccountPassword(for: account) else {
                return nil;
            }
            let client = self.createXmppClient(for: account);
            var wasConnected = false;
            client.connectionConfiguration.credentials = .password(password: password, authenticationName: nil, cache: nil);
            client.$state.dropFirst().sink(receiveValue: { [weak client] newState in
                switch newState {
                    case .connected(_):
                        guard let client = client else {
                            return;
                        }
                        wasConnected = true;
                        let recipients = self.recipients.filter({ $0.account == account });
                        switch attachment {
                            case .file(let tempUrl, let fileInfo):
                                self.upload(file: tempUrl, fileInfo: fileInfo, using: client, completionHandler: { result in
                                    try? FileManager.default.removeItem(at: tempUrl);
                                    switch result {
                                        case .success(let url):
                                            self.send(using: client, to: recipients, body: url.absoluteString, oob: url.absoluteString, completionHandler: {
                                                _ = client.disconnect();
                                            })
                                        case .failure(let err):
                                            DispatchQueue.main.async {
                                                errors.append(contentsOf: recipients.map({ ErrorResult(jid: $0.jid, error: err)}))
                                            }
                                            _ = client.disconnect();
                                    }
                                });
                            case .link(let url):
                                self.send(using: client, to: recipients, body: url.absoluteString, oob: nil, completionHandler: {
                                    _ = client.disconnect();
                                })
                            case .text(let text):
                                self.send(using: client, to: recipients, body: text, oob: nil, completionHandler: {
                                    _ = client.disconnect();
                                })
                        }
                        break;
                    case .disconnected:
                        if !wasConnected {
                            let recipients = self.recipients.filter({ $0.account == account });
                            DispatchQueue.main.async {
                                errors.append(contentsOf: recipients.map({ ErrorResult(jid: $0.jid, error: ShareError.unknownError)}))
                            }
                        }
                        group.leave();
                    default:
                        break;
                }
            }).store(in: &cancellables);
            group.enter();
            client.login();
            return client;
        })
        group.notify(queue: DispatchQueue.main, execute: {
            completionHandler(errors);
        })
    }

    private func send(using client: XMPPClient, to recipients: [RosterItem], body: String?, oob: String?, completionHandler: @escaping ()->Void) {
        let group = DispatchGroup();
        for recipient in recipients {
            group.enter();
            let message = Message(elem: Element(name: "message"));
            message.type = .chat;
            message.to = JID(recipient.jid)
            message.id = UUID().uuidString;
            message.body = body;
            message.oob = oob;
            client.writer.write(message, writeCompleted: { result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    group.leave();
                })
            });
        }
        group.notify(queue: DispatchQueue.main, execute: completionHandler);
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rosterItems.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipientTableViewCell", for: indexPath);
        let item = rosterItems[indexPath.row];
        cell.imageView?.image = avatar(for: item) ?? generateAvatar(for: item);
        cell.imageView?.layer.cornerRadius = 20;
        cell.imageView?.layer.masksToBounds = true;
        cell.textLabel?.text = item.displayName;
        cell.detailTextLabel?.text = item.jid.stringValue;
        if recipients.contains(item) {
            cell.accessoryType = .checkmark;
        } else {
            cell.accessoryType = .none;
        }
        return cell;
    }

    func avatar(for item: RosterItem) -> UIImage? {
        guard let hash = avatars[.init(account: item.account, jid: item.jid, type: .pepUserAvatar)] ?? avatars[.init(account: item.account, jid: item.jid, type: .vcardTemp)] else {
            return nil;
        }

        guard let path = avatarCacheUrl?.appendingPathComponent(hash).path else {
            return nil;
        }

        return UIImage(contentsOfFile: path)?.scaled(maxWidthOrHeight: 40);
    }

    func generateAvatar(for item: RosterItem) -> UIImage? {
        guard let initials = item.initials else {
            return nil;
        }

        let scale = UIScreen.main.scale;
        let size = CGSize(width: 40, height: 40);
        UIGraphicsBeginImageContextWithOptions(size, false, scale);
        let ctx = UIGraphicsGetCurrentContext()!;
        let path = CGPath(ellipseIn: CGRect(origin: .zero, size: size), transform: nil);
        ctx.addPath(path);

        let colors = [UIColor.systemGray.withAlphaComponent(0.52).cgColor, UIColor.systemGray.withAlphaComponent(0.48).cgColor];
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 1.0])!;
        ctx.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 0, y: size.height), options: []);

        let textAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white.withAlphaComponent(0.9), .font: UIFont.systemFont(ofSize: size.width * 0.4, weight: .medium)];
        let textSize = initials.size(withAttributes: textAttr);

        initials.draw(in: CGRect(x: size.width/2 - textSize.width/2, y: size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height), withAttributes: textAttr);

        let image = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();

        return image;
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = rosterItems[indexPath.row];
        if let idx = recipients.firstIndex(of: item) {
            recipients.remove(at: idx);
        } else {
            recipients.append(item);
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = !recipients.isEmpty;
        tableView.reloadData();
    }

    private func createXmppClient(for account: BareJID) -> XMPPClient {
        let client = XMPPClient();

        client.connectionConfiguration.modifyConnectorOptions(type: SocketConnectorNetwork.Options.self, { options in
            options.networkProcessorProviders.append(SSLProcessorProvider());
            options.connectionTimeout = 15;
            options.sslCertificateValidation = .customValidator({ _ in
                return true;
            })
        })
        client.connectionConfiguration.userJid = account;

        _ = client.modulesManager.register(AuthModule());
        _ = client.modulesManager.register(StreamFeaturesModule());
        _ = client.modulesManager.register(SaslModule());
        _ = client.modulesManager.register(ResourceBinderModule());
        _ = client.modulesManager.register(SessionEstablishmentModule());
        _ = client.modulesManager.register(DiscoveryModule());
        client.modulesManager.register(PresenceModule()).initialPresence = false;
        _ = client.modulesManager.register(HttpFileUploadModule());

        return client;
    }

    func getMimeType(for localURL: URL) -> String? {
        do {
            let uti = try localURL.resourceValues(forKeys: [.contentTypeKey]).contentType
            return uti?.preferredMIMEType
        } catch {
            print("Error: \(error)")
            return nil
        }
    }


    private func upload(file localUrl: URL, fileInfo: ShareFileInfo, using client: XMPPClient, completionHandler: @escaping (Result<URL,Error>)->Void) {
        let uti = try? localUrl.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier;

        let mimeType = uti != nil ? getMimeType(for: localUrl) : nil;

        let size = try! FileManager.default.attributesOfItem(atPath: localUrl.path)[FileAttributeKey.size] as! UInt64;

        guard let inputStream = InputStream(url: localUrl) else {
            completionHandler(.failure(ShareError.noAccessError));
            return;
        }

        HTTPFileUploadHelper.upload(for: client, filename: fileInfo.filenameWithSuffix, inputStream: inputStream, filesize: Int(size), mimeType: mimeType ?? "application/octet-stream", delegate: nil, completionHandler: { result in
            switch result {
                case .success(let url):
                    completionHandler(.success(url));
                case .failure(let error):
                    completionHandler(.failure(error));
            }
        })
    }

    enum Attachment {
        case file(URL, ShareFileInfo)
        case link(URL)
        case text(String)
    }

    private func extractAttachments(completionHandler: @escaping (Result<Attachment,Error>)->Void) {
        if let provider = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments?.first {
            if provider.hasItemConformingToTypeIdentifier(UTType.video.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.video.identifier, completionHandler: { url, error in
                    guard let url = url else {
                        completionHandler(.failure(error!));
                        return;
                    }
                    MediaHelper.compressMovie(url: url, fileInfo: ShareFileInfo.from(url: url, defaultSuffix: "mov"), quality: self.videoQuality, progressCallback: { progress in }, completionHandler: { result in
                        try? FileManager.default.removeItem(at: url);
                        switch result {
                            case .success((let url, let fileInfo)):
                                completionHandler(.success(.file(url, fileInfo)))
                            case .failure(let error):
                                completionHandler(.failure(error));
                        }
                    })
                });
            } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier, completionHandler: { url, error in
                    guard let url = url else {
                        completionHandler(.failure(error!));
                        return;
                    }
                    MediaHelper.compressImage(url: url, fileInfo: ShareFileInfo.from(url: url, defaultSuffix: "jpg"), quality: self.imageQuality, completionHandler: { result in
                        try? FileManager.default.removeItem(at: url);
                        switch result {
                            case .success((let url, let fileInfo)):
                                completionHandler(.success(.file(url, fileInfo)))
                            case .failure(let error):
                                completionHandler(.failure(error));
                        }
                    })
                });
            } else if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil, completionHandler: { (item, error) in
                    guard let url = item as? URL else {
                        completionHandler(.failure(error!));
                        return;
                    }
                    let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString);
                    do {
                        try FileManager.default.copyItem(at: url, to: tempUrl);
                        completionHandler(.success(.file(tempUrl, ShareFileInfo.from(url: url, defaultSuffix: nil))));
                    } catch {
                        completionHandler(.failure(error));
                    }
                });
            } else if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil, completionHandler: { (item, error) in
                    guard let url = item as? URL else {
                        completionHandler(.failure(error!));
                        return;
                    }
                    completionHandler(.success(.link(url)));
                })
            } else if provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil, completionHandler: { (item, error) in
                    guard let text = item as? String else {
                        completionHandler(.failure(error!));
                        return;
                    }
                    completionHandler(.success(.text(text)));
                })
            } else {
                completionHandler(.failure(ShareError.notSupported));
            }
        } else {
            completionHandler(.failure(ShareError.noAccessError));
        }
    }

    func show(error: Error) {
        showAlert(title: NSLocalizedString("Failure", comment: "alert title"), message: (error as? ShareError)?.message ?? error.localizedDescription);
    }

    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "button label"), style: .default, handler: {(action) in
                self.extensionContext?.cancelRequest(withError: ShareError.unknownError);
            }));
            self.present(alert, animated: true, completion: nil);
        }
    }

    func getActiveAccounts() -> [BareJID] {
        var accounts = [BareJID]();
        let query = [ String(kSecClass) : kSecClassGenericPassword, String(kSecMatchLimit) : kSecMatchLimitAll, String(kSecReturnAttributes) : kCFBooleanTrue as Any, String(kSecAttrService) : "xmpp" ] as [String : Any];
        var result:AnyObject?;

        let lastResultCode: OSStatus = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0));
        }

        if lastResultCode == noErr {
            if let results = result as? [[String:NSObject]] {
                for r in results {
                    if let name = r[String(kSecAttrAccount)] as? String {
                        if let data = r[String(kSecAttrGeneric)] as? NSData {
                            NSKeyedUnarchiver.setClass(ServerCertificateInfo.self, forClassName: "ServerCertificateInfo");
                            let dict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:AnyObject];
                            if dict!["active"] as? Bool ?? true {
                                accounts.append(BareJID(name));
                            }
                        }
                    }
                }
            }

        }
        return accounts;
    }

    func getAccountPassword(for account: BareJID) -> String? {
        let query: [String: NSObject] = [ String(kSecClass) : kSecClassGenericPassword, String(kSecMatchLimit) : kSecMatchLimitOne, String(kSecReturnData) : kCFBooleanTrue, String(kSecAttrService) : "xmpp" as NSObject, String(kSecAttrAccount) : account.stringValue as NSObject ];

        var result:AnyObject?;

        let lastResultCode: OSStatus = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0));
        }

        if lastResultCode == noErr {
            if let data = result as? NSData {
                return String(data: data as Data, encoding: String.Encoding.utf8);
            }
        }
        return nil;
    }

}
