//
//  File.swift
//  
//
//  Created by warren on 6/16/22.
//

import Foundation

extension Tr3EdgeDefs {

    func printVal() -> String {
        return scriptVal([.now])
    }

    func scriptVal(_ scriptFlags: Tr3ScriptFlags) -> String {

        var script = ""

        for edgeDef in edgeDefs {

            let val = edgeDef.scriptVal(scriptFlags)

            script += val
        }
        return script
    }
}
