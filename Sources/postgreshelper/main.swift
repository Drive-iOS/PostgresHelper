import Foundation
import ArgumentParser

struct PostgresSetUp: ParsableCommand {
    @Argument(help: "The config's file path")
    var configAbsolutePath: String

    mutating func run() throws {
        let configURL = URL(fileURLWithPath: configAbsolutePath)

        guard let configData = try? Data(contentsOf: configURL),
              let _ = try? JSONDecoder().decode(Config.self, from: configData) else {
            return
        }

        // TODO: (Aman Ketebo) Check current hash against drive api repo's build script hash
    }
}

PostgresSetUp.main()
