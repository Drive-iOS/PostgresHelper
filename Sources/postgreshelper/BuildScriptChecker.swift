//
//  BuildScriptChecker.swift
//  
//
//  Created by Amanuel Ketebo on 11/28/20.
//

import Foundation

class BuildScriptChecker {
    // MARK: - Properties

    let config: Config
    let fileManager: FileManager

    // MARK: - Init

    init(config: Config,
         fileManager: FileManager = .default) {
        self.config = config
        self.fileManager = fileManager
    }

    // MARK: - Checking

    func shouldUpdateTables() -> Bool {
        let buildScriptString = self.buildScriptString()
        let savedBuildScriptString = self.savedBuildScriptString()

        return buildScriptString != savedBuildScriptString
    }

    // MARK: - Saving

    func saveCurrentBuildScriptString() {
        let currentBuildScriptString = buildScriptString()

        if fileManager.fileExists(atPath: config.postgres.savedBuildScript.absolutePath) {
            do {
                try currentBuildScriptString.write(toFile: config.postgres.savedBuildScript.absolutePath,
                                              atomically: true,
                                              encoding: .utf8)
            } catch {
                print("❌ Failed to save current build string")
                exit(1)
            }
        } else {
            let successfullyCreatedFile = fileManager.createFile(atPath: config.postgres.savedBuildScript.absolutePath,
                                                                 contents: Data(currentBuildScriptString.utf8),
                                                                 attributes: nil)

            if successfullyCreatedFile {
                print("❌ Failed to save current build string")
                exit(1)
            }
        }
    }

    // MARK: - Helpers

    private func buildScriptString() -> String {
        let buildScriptURL = URL(fileURLWithPath: config.driveAPIRepo.buildScriptAbsolutePath)

        do {
            return try String(contentsOf: buildScriptURL)
        } catch {
            print("❌ Failed to get string from build script")
            exit(1)
        }
    }

    func savedBuildScriptString() -> String {
        let savedBuildScriptURL = URL(fileURLWithPath: config.postgres.savedBuildScript.absolutePath)

        do {
            return try String(contentsOf: savedBuildScriptURL)
        } catch {
            print("❌ Failed to get string from saved build script")
            exit(1)
        }
    }
}
