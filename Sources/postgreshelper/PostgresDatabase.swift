//
//  PostgresDatabase.swift
//  
//
//  Created by Amanuel Ketebo on 11/28/20.
//

import Foundation

class PostgresDatabase: LauncherProtocol {

    // MARK: - Properties

    private let config: Config
    private let fileManager: FileManager
    private lazy var windowIDSaver = WindowIDSaver(config: config, fileManager: fileManager)

    // MARK: - Init

    init(config: Config,
         fileManager: FileManager = .default) {
        self.config = config
        self.fileManager = fileManager
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
        closeRunningPostgresDatabaseIfNeeded()

        print("When is this happening wtf")

        let process = Process()
        let pipe = Pipe()

        process.launchPath = "/usr/bin/osascript"
        process.arguments = ["-e", "tell app \"Terminal\" to do script \"psql -d \(config.postgres.localDatabase.databaseName) -U \(config.postgres.localDatabase.username)\""]
        process.standardOutput = pipe
        
        do {
            try launch(process: process)
            process.waitUntilExit()
        } catch {
            print("❌ Failed to start server")
            exit(1)
        }

        print("Started server")

        let processOutputData = pipe.fileHandleForReading.readDataToEndOfFile()
        windowIDSaver.saveID(for: .postgres, from: processOutputData)
    }

    // MARK: - Helpers

    private func newServerProcess() -> Process {
        let process = Process()
        process.launchPath = "/usr/local/bin/psql"
        process.arguments = ["-d", "\(config.postgres.localDatabase.databaseName)",
                             "-U", "\(config.postgres.localDatabase.username)"]
        return process
    }

    private func closeRunningPostgresDatabaseIfNeeded() {
        guard fileManager.fileExists(atPath: config.savedRunningTerminals.absolutePath) else {
            return
        }

        guard let data = fileManager.contents(atPath: config.savedRunningTerminals.absolutePath),
              let runningTerminalsInfo = try? JSONDecoder().decode(RunningTerminalsInfo.self, from: data) else {
            return
        }

        guard let driveAPIRepoTerminalWindowID = runningTerminalsInfo.localPostgresTerminalWindowID else {
            return
        }

        guard let closeTerminalScriptPath = Bundle.module.path(forResource: "close-terminal", ofType: "applescript") else {
            return
        }

        print("attempting to close terminal terminal")
        print(closeTerminalScriptPath)
        print(driveAPIRepoTerminalWindowID)

        let process = Process()

        process.launchPath = "/usr/bin/osascript"
        process.arguments = [closeTerminalScriptPath, String(driveAPIRepoTerminalWindowID)]
        process.waitUntilExit()

        do {
            try launch(process: process)
        } catch {
            print("❌ Failed to start server")
            exit(1)
        }

        print("closing terminal")
    }
}
