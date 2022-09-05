//  Tr3EdgeDefs+script.swift
//
//  Created by warren on 4/5/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

/// + script
extension Tr3EdgeDef: Tr3ValScriptProtocol {

    func printVal() -> String {
        return scriptVal(parens: true, session: true, expand: true)
    }

    func scriptVal(parens: Bool,
                   session: Bool,
                   expand: Bool) -> String {

        var script = edgeFlags.script()

        if let tern = ternVal {
            script.spacePlus(tern.scriptVal(parens: parens, session: session))
        }
        else {
            if pathVals.pathVal.count > 1 { script += "(" }
            for (path,val) in pathVals.pathVal {
                script += path
                script += val?.scriptVal(expand: expand) ?? ""
            }
            if pathVals.pathVal.count > 1 { script += ")" }
        }
        return script
    }
}
