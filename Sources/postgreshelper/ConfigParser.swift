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

        guard let configData = try? Data(contentsOf: configURL),
              let config = try? JSONDecoder().decode(Config.self, from: configData) else {
            print("❌ Failed to parse config")
            exit(1)
        }

        return config
    }
}
