import Foundation

let sourceRootAbsolutePath = ProcessInfo.processInfo.environment["SRCROOT"] ?? ""
let config = ConfigParser.parse(from: sourceRootAbsolutePath + "/postgres-local-database-config.json")
let postgresDatabase = PostgresDatabase(config: config)
let buildScriptChecker = BuildScriptChecker(config: config,
                                            sourceRootAbsolutePath: sourceRootAbsolutePath)
let localDriveAPIServer = LocalDriveAPIServer(config: config)

if buildScriptChecker.shouldUpdateTables() {
    if !buildScriptChecker.savedBuildScriptString().isEmpty {
        postgresDatabase.dropAllTables()
    }

    postgresDatabase.addTables()
    buildScriptChecker.saveCurrentBuildScriptString()
}

postgresDatabase.startServer()
localDriveAPIServer.startServer()
