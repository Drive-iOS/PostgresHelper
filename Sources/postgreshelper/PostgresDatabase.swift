//
//  PostgresDatabase.swift
//  
//
//  Created by Amanuel Ketebo on 11/28/20.
//

import Foundation

class PostgresDatabase {

    // MARK: - Properties

    let config: Config

    // MARK: - Init

    init(config: Config) {
        self.config = config
    }

    // MARK: - Updating Tables

    func dropAllTables() {
        let process = newServerProcess()
        process.standardInput = FileHandle(forReadingAtPath: config.driveAPIRepo.dropTablesScriptAbsolutePath)

        do {
            try launch(process: process)
        } catch {
            print("❌ Failed to drop tables")
            exit(1)
        }
    }

    func addTables() {
        let process = newServerProcess()
        process.standardInput = FileHandle(forReadingAtPath: config.driveAPIRepo.buildScriptAbsolutePath)

        do {
            try launch(process: process)
        } catch {
            print("❌ Failed to add tables")
            exit(1)
        }
    }

    // MARK: - Start

    func startServer() {
        let process = Process()

        process.launchPath = "/usr/bin/osascript"
        process.arguments = ["-e", "tell app \"Terminal\" to do script \"psql -d \(config.postgres.localDatabase.databaseName) -U \(config.postgres.localDatabase.username)\""]
        
        do {
            try launch(process: process)
        } catch {
            print("❌ Failed to start server")
            exit(1)
        }
    }

    // MARK: - Helpers

    private func newServerProcess() -> Process {
        let process = Process()
        process.launchPath = "/usr/local/bin/psql"
        process.arguments = ["-d", "\(config.postgres.localDatabase.databaseName)",
                             "-U", "\(config.postgres.localDatabase.username)"]
        return process
    }

    private func launch(process: Process) throws {
        if #available(OSX 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }
    }
}
