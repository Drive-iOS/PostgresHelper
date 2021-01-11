//
//  File.swift
//  
//
//  Created by Amanuel Ketebo on 1/10/21.
//

import Foundation

struct RunningTerminalsInfo: Codable {
    var driveAPIRepoTerminalWindowID: Int?
    var localPostgresTerminalWindowID: Int?
}

class WindowIDSaver {

    // MARK: - Types

    enum IDType {
        case driveAPI
        case postgres
    }

    // MARK: - Properties

    private let config: Config
    private let fileManager: FileManager

    private var currentRunningTerminalsInfo: RunningTerminalsInfo? {
        guard fileManager.fileExists(atPath: config.savedRunningTerminals.absolutePath) else {
            return nil
        }

        guard let data = fileManager.contents(atPath: config.savedRunningTerminals.absolutePath),
              let runningTerminalsInfo = try? JSONDecoder().decode(RunningTerminalsInfo.self, from: data) else {
            return nil
        }

        return runningTerminalsInfo
    }

    // MARK: - Init

    init(config: Config,
         fileManager: FileManager = .default) {
        self.config = config
        self.fileManager = fileManager
    }

    // MARK: - Saving ID

    func saveID(for type: IDType, from startingTerminalOutputData: Data) {
        guard let windowID = parseWindowID(from: startingTerminalOutputData) else {
            return
        }

        let runningTerminalsInfo = createUpdatedRunningsTerminalsInfo(for: type, using: windowID)
        print("new terminal info: \(runningTerminalsInfo)")

        guard let data = try? JSONEncoder().encode(runningTerminalsInfo) else {
            return
        }

        saveUpdatedRunningsTerminalInfo(data: data)
    }

    private func parseWindowID(from data: Data) -> Int? {
        guard let dataString = String(data: data, encoding: .utf8) else {
            return nil
        }

        guard let windowIDString = dataString.split(separator: " ").last else {
            return nil
        }

        let cleanWindowIDString = windowIDString.trimmingCharacters(in: .whitespacesAndNewlines)

        print("new window id \(cleanWindowIDString)")
        return Int(cleanWindowIDString)
    }

    private func createUpdatedRunningsTerminalsInfo(for type: IDType, using windowID: Int) -> RunningTerminalsInfo {
        // TODO: (Aman Ketebo) Might be a better way to simplify this
        var updatedRunningTerminalsInfo = currentRunningTerminalsInfo ?? RunningTerminalsInfo(driveAPIRepoTerminalWindowID: nil,
                                                                                              localPostgresTerminalWindowID: nil)

        if currentRunningTerminalsInfo != nil {
            switch type {
            case .driveAPI:
                updatedRunningTerminalsInfo.driveAPIRepoTerminalWindowID = windowID

            case .postgres:
                updatedRunningTerminalsInfo.localPostgresTerminalWindowID = windowID
            }
        } else {
            switch type {
            case .driveAPI:
                updatedRunningTerminalsInfo = RunningTerminalsInfo(driveAPIRepoTerminalWindowID: windowID,
                                                                   localPostgresTerminalWindowID: nil)
            case .postgres:
                updatedRunningTerminalsInfo = RunningTerminalsInfo(driveAPIRepoTerminalWindowID: nil,
                                                                   localPostgresTerminalWindowID: windowID)
            }
        }

        return updatedRunningTerminalsInfo
    }

    private func saveUpdatedRunningsTerminalInfo(data: Data) {
        if fileManager.fileExists(atPath: config.savedRunningTerminals.absolutePath) {
            let url = URL(fileURLWithPath: config.savedRunningTerminals.absolutePath)
            do {
                try data.write(to: url)
            } catch {
                return
            }
        } else {
            fileManager.createFile(atPath: config.savedRunningTerminals.absolutePath,
                                   contents: data,
                                   attributes: nil)
        }
    }
}
