//  Tr3EdgeDefs+script.swift
//
//  Created by warren on 4/5/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

extension Tr3EdgeDef: Tr3ValScriptProtocol {

    static func scriptEdgeFlag(_ flags: Tr3EdgeFlags, _ active: Bool = true) -> String {

        let hasImplicitEdge = flags.intersection([.solo,.ternary,.copyat]) != []
        if hasImplicitEdge || active == false {
            var script = flags.contains(.input) ? "←" : ""
            if      active == false          { script += "◇" }
            else if flags.contains(.solo)    { script += "⟡" }
            else if flags.contains(.ternary) { script += "⟐" }
            else if flags.contains(.copyat)  { script += "@" }
            else if active == false          { script += "◇" }
            script += flags.contains(.output) ? "→" : ""
            return script
        } else {
            switch flags {
                case [.input,.output]: return "<>"
                case [.input]: return "<<"
                case [.output]: return ">>"
                default: print( "⚠️ unexpected scriptEdgeFlag")
            }
        }
        return ""
    }
    func printVal() -> String {
        return scriptVal(parens: true, session: true, expand: true)
    }

    func scriptVal(parens: Bool,
                   session: Bool,
                   expand: Bool) -> String {

        var script = Tr3EdgeDef.scriptEdgeFlag(edgeFlags)

        if let tern = ternVal {
            script.spacePlus(tern.scriptVal(parens: parens, session: session))
        }
        else {
            if pathVals.pathDict.count > 1 { script += "(" }
            for (path,val) in pathVals.pathDict {
                script.spacePlus(path)
                script.spacePlus(val?.scriptVal(expand: expand) ?? "")
            }
            if pathVals.pathDict.count > 1 { script += ")" }
        }
        return script
    }
}
