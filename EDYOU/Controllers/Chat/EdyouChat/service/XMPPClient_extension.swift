//
// XMPPClient_extension.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin

extension XMPPClient {
    
    fileprivate static let RETRY_NO_KEY = "retryNo";
    
    var retryNo: Int {
        get {
            return sessionObject.getProperty(XMPPClient.RETRY_NO_KEY) ?? 0;
        }
        set {
            sessionObject.setUserProperty(XMPPClient.RETRY_NO_KEY, value: newValue);
        }
    }
    
}

extension SocketConnectorNetwork.Endpoint: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self);
        self.init(proto: ConnectorProtocol(rawValue: try container.decode(String.self, forKey: .proto))!, host: try container.decode(String.self, forKey: .host), port: try container.decode(Int.self, forKey: .port));
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self);
        try container.encode(proto.rawValue, forKey: .proto);
        try container.encode(host, forKey: .host);
        try container.encode(port, forKey: .port);
    }
    
    public enum CodingKeys: String, CodingKey {
        case proto
        case host
        case port
    }
}
