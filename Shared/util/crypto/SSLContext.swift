//
//  SSLContext.swift
//  Shared
//
//  Created by imac3 on 18/12/2023.
//  Copyright © 2023 Tigase, Inc. All rights reserved.
//

import Foundation
import uxmpp
import OpenSSL

open class SSLContext {
    
    private let sslContext: OpaquePointer;
    
    public init?(alpnProtocols: [String] = [], supportedTlsVersions: ClosedRange<SSLProtocol> = SSLProtocol.TLSv1_2...SSLProtocol.TLSv1_3) {
        guard let context = SSL_CTX_new(TLS_client_method()) else {
            return nil;
        }
        sslContext = context;
        if !alpnProtocols.isEmpty {
            var bytes = alpnProtocols.map { SSLContext.protocolToBytes($0) }.reduce(into: [UInt8](repeating: 0, count: 0), { result, value in result.append(contentsOf: value) });
            SSL_CTX_set_alpn_protos(context, &bytes, UInt32(bytes.count));
        }

        var options = UInt(0) | UInt(SSL_OP_NO_SSLv2) | UInt(SSL_OP_NO_SSLv3) | UInt(SSL_OP_NO_COMPRESSION);
        for version in SSLProtocol.allCases {
            if !supportedTlsVersions.contains(version) {
                options = options | UInt(version.ssl_op_no);
            }
        }

        SSL_CTX_set_options(context, options)

        SSL_CTX_ctrl(context, SSL_CTRL_SET_SESS_CACHE_MODE, Int(SSL_SESS_CACHE_CLIENT | SSL_SESS_CACHE_NO_INTERNAL_STORE), nil);
    }
    
    deinit {
        SSL_CTX_free(sslContext);
    }
    
    open func createConnection() -> SSLProcessor? {
        guard let ssl = SSL_new(sslContext) else {
            return nil;
        }
        return SSLProcessor(ssl: ssl, context: self);
    }
      
    private static func protocolToBytes(_ proto: String) -> [UInt8] {
        let data = proto.data(using: .utf8)!;
        var bytes: [UInt8] = [UInt8](repeating: 0, count: data.count);
        data.copyBytes(to: &bytes, count: data.count);
        return [UInt8(data.count)] + bytes;
    }
}
