//
//  File.swift
//  
//
//  Created by Amanuel Ketebo on 11/20/20.
//

import Foundation

struct Config: Decodable {
    let postgres: ConfigPostgres
}

struct ConfigPostgres: Decodable {
    let localDatabase: ConfigLocalDatabase
}

struct ConfigLocalDatabase: Decodable {
    let databaseName: String
    let username: String
    let password: String
}
