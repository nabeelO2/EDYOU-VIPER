//
// ServerCertificateInfo.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin

open class ServerCertificateInfo: SslCertificateInfo {
    
    public var accepted: Bool;
    
    public override init(trust: SecTrust) {
        self.accepted = false;
        super.init(trust: trust);
    }
    
    public init(sslCertificateInfo: SslCertificateInfo, accepted: Bool) {
        self.accepted = accepted;
        super.init(sslCertificateInfo: sslCertificateInfo);
    }
    
    public required init?(coder aDecoder: NSCoder) {
        accepted = aDecoder.decodeBool(forKey: "accepted");
        super.init(coder: aDecoder);
    }
    
    public override func encode(with aCoder: NSCoder) {
        aCoder.encode(accepted, forKey: "accepted");
        super.encode(with: aCoder);
    }
    
}
