//
//  ConfigParser.swift
//  
//
//  Created by Amanuel Ketebo on 11/28/20.
//

import Foundation

enum ConfigParser {
    static func parse(from absolutePath: String) -> Config {
        let configURL = URL(fileURLWithPath: absolutePath)
        let config: Config
        do {
            let configData = try Data(contentsOf: configURL)
            config = try JSONDecoder().decode(Config.self, from: configData)
        } catch {
            print("❌ Failed to parse config")
            print("- \(error.localizedDescription)")
            exit(1)
        }

        return config
    }
}
