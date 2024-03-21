//
// CertificateErrorAlert.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Martin

class CertificateErrorAlert {
    
    public static func create(domain: String, certData: SslCertificateInfo, onAccept: (()->Void)?, onDeny: (()->Void)?) -> UIAlertController {
        return create(domain: domain, certName: certData.details.name, certHash: certData.details.fingerprintSha1, issuerName: certData.issuer?.name, issuerHash: certData.issuer?.fingerprintSha1, onAccept: onAccept, onDeny: onDeny);
    }
    
    public static func create(domain: String, certName: String, certHash: String, issuerName: String?, issuerHash: String?, onAccept: (()->Void)?, onDeny: (()->Void)?) -> UIAlertController {
        let issuer = issuerName != nil ? String.localizedStringWithFormat(NSLocalizedString("\nissued by\n%@\n with fingerprint\n%@", comment: "ssl certificate info - issue part"), issuerName!, issuerHash!) : "";
        let alert = UIAlertController(title: NSLocalizedString("Certificate issue", comment: "alert title"), message: String.localizedStringWithFormat(NSLocalizedString("Server for domain %@ provided invalid certificate for %@\n with fingerprint\n%@%@.\nDo you trust this certificate?", comment: "ssl certificate alert dialog body"), domain, certName, certHash, issuer), preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "button label"), style: .cancel, handler: CertificateErrorAlert.wrapActionHandler(onDeny)));
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "button label"), style: .destructive, handler: CertificateErrorAlert.wrapActionHandler(onAccept)));
        return alert;
    }
    
    fileprivate static func wrapActionHandler(_ action: (()->Void)?) -> ((UIAlertAction)->Void)? {
        guard action != nil else {
            return nil;
        }
        return {(aa) in action!(); };
    }
    
}
