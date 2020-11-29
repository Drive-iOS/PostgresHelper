import Foundation
import ArgumentParser

struct PostgresSetUp: ParsableCommand {
    @Argument(help: "The config's file path")
    var configAbsolutePath: String

    mutating func run() throws {
        let config = ConfigParser.parse(from: configAbsolutePath)
        let postgresDatabase = PostgresDatabase(config: config)
        let buildScriptChecker = BuildScriptChecker(config: config)

        if buildScriptChecker.shouldUpdateTables() {
            if buildScriptChecker.savedBuildScriptString().isEmpty {
                postgresDatabase.dropAllTables()
            }

            postgresDatabase.addTables()
            buildScriptChecker.saveCurrentBuildScriptString()
        }
    }
}

PostgresSetUp.main()
