//
//  LocalDriveServer.swift
//  
//
//  Created by Amanuel Ketebo on 12/19/20.
//

import Foundation

class LocalDriveAPIServer {
    let config: Config

    init(config: Config) {
        self.config = config
    }

    func startServer() {
        let process = Process()

        process.launchPath = "/usr/bin/osascript"
        process.arguments = ["-e", "tell app \"Terminal\" to do script \"cd \(config.driveAPIRepo.repoAbsolutePath) && npm start\""]

        do {
            try launch(process: process)
        } catch {
            print("❌ Failed to start server")
            exit(1)
        }
    }

    private func launch(process: Process) throws {
        if #available(OSX 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }
    }
}
