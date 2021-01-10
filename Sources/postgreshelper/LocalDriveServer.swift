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


        // TODO: (Aman Ketebo) Clean up processing of output
        if #available(macOS 10.15.4, *)  {
            guard let processOutputData = try? pipe.fileHandleForReading.readToEnd() else {
                return
            }

            guard let processOutput = String(data: processOutputData, encoding: .utf8) else {
                return
            }

            guard let lastPortionOfProcessOutput = processOutput.split(separator: " ").last else {
                return
            }

            let windowIDString = String(lastPortionOfProcessOutput).trimmingCharacters(in: .whitespacesAndNewlines)

            guard let windowID = Int(windowIDString) else {
                return
            }

            print("Here's the window ID for local postgres drive server: \(windowID)")
        }
    }

    private func closeRunningAPIServerIfNeeded() {
        guard fileManager.fileExists(atPath: config.savedRunningTerminals.absolutePath) else {
            return
        }

        guard let data = fileManager.contents(atPath: config.savedRunningTerminals.absolutePath),
              let runningTerminalsInfo = try? JSONDecoder().decode(RunningTerminalsInfo.self, from: data) else {
            return
        }

        guard let closeTerminalScriptPath = Bundle.module.path(forResource: "close-terminal", ofType: "applescript") else {
            return
        }

        let process = Process()

        process.launchPath = "/usr/bin/osascript"
        process.arguments = [closeTerminalScriptPath, String(runningTerminalsInfo.driveAPIRepoTerminalWindowID)]

        do {
            try launch(process: process)
        } catch {
            print("❌ Failed to start server")
            exit(1)
        }
    }
}

struct RunningTerminalsInfo: Codable {
    let driveAPIRepoTerminalWindowID: Int
}
