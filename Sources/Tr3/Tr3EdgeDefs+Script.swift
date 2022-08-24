//
//  File.swift
//  
//
//  Created by warren on 6/16/22.
//

import Foundation

extension Tr3EdgeDefs: Tr3ValScriptProtocol {

    func printVal() -> String {
        return scriptVal(session: true)
    }

    func scriptVal(parens: Bool = true,
                   session: Bool = false,
                   expand: Bool = false) -> String {
        var script = ""
        for edgeDef in edgeDefs {
            let val = edgeDef.scriptVal(parens: parens, session: session, expand: expand)
            script.spacePlus(val)
        }
        return script
    }
}
