//
//  Config.swift
//  
//
//  Created by Amanuel Ketebo on 11/20/20.
//

import Foundation

struct Config: Decodable {
    let postgres: ConfigPostgres
    let driveAPIRepo: ConfigDriveAPIRepo
}

struct ConfigPostgres: Decodable {
    let localDatabase: ConfigLocalDatabase
    let savedBuildScript: ConfigSavedBuildScript
}

struct ConfigLocalDatabase: Decodable {
    let databaseName: String
    let username: String
}

struct ConfigSavedBuildScript: Decodable {
    let absolutePath: String
}

struct ConfigDriveAPIRepo: Decodable {
    let repoAbsolutePath: String
    let buildScriptAbsolutePath: String
    let dropTablesScriptAbsolutePath: String
}
