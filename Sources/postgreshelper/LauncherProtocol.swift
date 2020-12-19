//
//  LauncherProtocol.swift
//  
//
//  Created by Amanuel Ketebo on 12/19/20.
//

import Foundation

protocol LauncherProtocol {
    func launch(process: Process) throws
}

extension LauncherProtocol {
    func launch(process: Process) throws {
        if #available(OSX 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }
    }
}
