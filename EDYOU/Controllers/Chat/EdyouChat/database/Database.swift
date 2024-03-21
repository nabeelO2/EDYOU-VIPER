//
// Database.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import TigaseSQLite3
import Martin
import TigaseLogging

extension Database {
    
    static let main: DatabasePool = {
        return try! DatabasePool(dbUrl: mainDatabaseUrl(), schemaMigrator: DatabaseMigrator());
    }();
    
}

extension DatabasePool {
    
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "sqlite");
    
    convenience init(dbUrl: URL, schemaMigrator: DatabaseSchemaMigrator? = nil) throws {
        try self.init(configuration: Configuration(path: dbUrl.path, schemaMigrator: schemaMigrator));
        DatabasePool.logger.info("Initialized database: \(dbUrl.path)");
    }
}


