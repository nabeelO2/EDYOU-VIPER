//
//  SSLCertificate.swift
//  Shared
//
//  Created by imac3 on 18/12/2023.
//  Copyright © 2023 Tigase, Inc. All rights reserved.
//

import Foundation
import OpenSSL

open class SSLCertificate {
    
    private let ref: OpaquePointer;
    
    init(withOwnedReference ref: OpaquePointer) {
        self.ref = ref;
    }
    
    deinit {
        X509_free(ref);
    }
    
    open func derCertificateData() -> Data? {
        var buf: UnsafeMutablePointer<UInt8>? = nil;
        
        let len = i2d_X509(self.ref, &buf);
        guard len >= 0 else {
            return nil;
        }
        
        defer {
            X509_free(OpaquePointer.init(buf));
        }
        
        return Data(bytes: UnsafeRawPointer(buf!), count: Int(len));
    }
    
    open func secCertificate() -> SecCertificate? {
        guard let data = derCertificateData() else {
            return nil;
        }
        return SecCertificateCreateWithData(nil, data as CFData);
    }
    
    open func secTrust() -> SecTrust? {
        guard let cert = secCertificate() else {
            return nil;
        }
        var commonName: CFString?;
        SecCertificateCopyCommonName(cert, &commonName);
        var trust: SecTrust?;
        guard SecTrustCreateWithCertificates([cert] as CFArray, SecPolicyCreateBasicX509(), &trust) == errSecSuccess else {
            return nil;
        }
        return trust;
    }
}

