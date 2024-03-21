//
// ConversationAttachment.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import Martin

public struct ChatAttachmentAppendix: AppendixProtocol, Hashable {
    
    var state: State = .new;
    var filesize: Int? = nil;
    var mimetype: String? = nil;
    var filename: String? = nil;
    
    init() {}
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self);
        state = State(rawValue: try container.decode(Int.self, forKey: .state))!;
        filesize = try container.decodeIfPresent(Int.self, forKey: .filesize);
        mimetype = try container.decodeIfPresent(String.self, forKey: .mimetype);
        filename = try container.decodeIfPresent(String.self, forKey: .filename);
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self);
        try container.encode(state.rawValue, forKey: .state);
        
        if let filesize = self.filesize {
            try container.encode(filesize, forKey: .filesize);
        }
        if let mimetype = self.mimetype {
            try container.encode(mimetype, forKey: .mimetype);
        }
        if let filename = self.filename {
            try container.encode(filename, forKey: .filename);
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case state = "state"
        case filesize = "size"
        case mimetype = "mimetype"
        case filename = "name"
    }
    
    enum State: Int {
        case new
        case downloaded
        case removed
        case tooBig
        case error
        case gone
    }
}
