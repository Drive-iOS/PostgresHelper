//
//  LocalDriveServer.swift
//  
//
//  Created by Amanuel Ketebo on 12/19/20.
//

import Foundation

class LocalDriveAPIServer: LauncherProtocol {
    let config: Config
    let fileManager: FileManager

    lazy var windowIDSaver = WindowIDSaver(config: config, fileManager: fileManager)

    init(config: Config,
         fileManager: FileManager = .default) {
        self.config = config
        self.fileManager = fileManager
    }

    func startServer() {
        closeRunningAPIServerIfNeeded()

        let process = Process()
        let pipe = Pipe()

        process.launchPath = "/usr/bin/osascript"
        process.arguments = ["-e", "tell app \"Terminal\" to do script \"cd \(config.driveAPIRepo.repoAbsolutePath) && npm start\""]
        process.standardOutput = pipe

        do {
            try launch(process: process)
        } catch {
            print("❌ Failed to start server")
            exit(1)
        }

        let processOutputData = pipe.fileHandleForReading.readDataToEndOfFile()
        windowIDSaver.saveID(for: .postgres, from: processOutputData)
    }

    private func closeRunningAPIServerIfNeeded() {
        guard fileManager.fileExists(atPath: config.savedRunningTerminals.absolutePath) else {
            return
        }

        guard let data = fileManager.contents(atPath: config.savedRunningTerminals.absolutePath),
              let runningTerminalsInfo = try? JSONDecoder().decode(RunningTerminalsInfo.self, from: data) else {
            return
        }

        guard let driveAPIRepoTerminalWindowID = runningTerminalsInfo.driveAPIRepoTerminalWindowID else {
            return
        }

        guard let closeTerminalScriptPath = Bundle.module.path(forResource: "close-terminal", ofType: "applescript") else {
            return
        }

        let process = Process()

        process.launchPath = "/usr/bin/osascript"
        process.arguments = [closeTerminalScriptPath, String(driveAPIRepoTerminalWindowID)]

        do {
            try launch(process: process)
        } catch {
            print("❌ Failed to start server")
            exit(1)
        }
    }
}
