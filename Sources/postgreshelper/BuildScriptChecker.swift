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

    private let savedBuildScriptAbsolutePath: String

    // MARK: - Init

    init(config: Config,
         fileManager: FileManager = .default,
         sourceRootAbsolutePath: String) {
        self.config = config
        self.fileManager = fileManager
        self.savedBuildScriptAbsolutePath = sourceRootAbsolutePath + "/postgres-saved-build-script.txt"
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

        if fileManager.fileExists(atPath: savedBuildScriptAbsolutePath) {
            do {
                try currentBuildScriptString.write(toFile: savedBuildScriptAbsolutePath,
                                              atomically: true,
                                              encoding: .utf8)
            } catch {
                print("❌ Failed to save current build string - file existed")
                exit(1)
            }
        } else {
            let successfullyCreatedFile = fileManager.createFile(atPath: savedBuildScriptAbsolutePath,
                                                                 contents: Data(currentBuildScriptString.utf8),
                                                                 attributes: nil)

            if !successfullyCreatedFile {
                print("❌ Failed to save current build string - file DID NOT exist")
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
        let savedBuildScriptURL = URL(fileURLWithPath: savedBuildScriptAbsolutePath)

        guard fileManager.fileExists(atPath: savedBuildScriptAbsolutePath) else {
            return ""
        }

        do {
            return try String(contentsOf: savedBuildScriptURL)
        } catch {
            print("❌ Failed to get string from saved build script")
            exit(1)
        }
    }
}
