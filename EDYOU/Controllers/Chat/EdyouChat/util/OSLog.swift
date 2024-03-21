//
// OSLog.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//
import Foundation
import os

extension OSLog {
    
    private static var subsystem = Bundle.main.bundleIdentifier!;
    
    static let chatStore = OSLog(subsystem: subsystem, category: "ChatStore");
    static let chatHistorySync = OSLog(subsystem: subsystem, category: "mam-sync");
    static let jingle = OSLog(subsystem: subsystem, category: "jingle");
    static let avatar = OSLog(subsystem: subsystem, category: "avatar");
}
