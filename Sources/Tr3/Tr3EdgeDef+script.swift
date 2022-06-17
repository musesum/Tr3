//  Tr3EdgeDefs+script.swift
//
//  Created by warren on 4/5/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

extension Tr3EdgeDef: Tr3ValScriptProtocol {

    static func scriptEdgeFlag(_ flags: Tr3EdgeFlags, _ active: Bool = true) -> String {

        //  most common use cases
        switch (flags, active) {
            case (.input, true): return "<<"
            case (.input, false): return "<╌"
            case (.output, true): return ">>"
            case (.output, false): return "╌>"
            case ([.input,.output], true): return "<>"
            case ([.input,.output], false): return "<╌>"
            default: break
        }

        // more complex uses
        var script =  flags.contains(.input) ? "<" : ""
        
        if      flags.contains(.solo)    { script += "=" }
        else if flags.contains(.find)    { script += ":" }
        else if flags.contains(.ternary) { script += "⋯" }
        else if flags.contains(.copyat)  { script += ":" }
        else if active == false          { script += "╌" }

        if flags.contains(.output)       { script += ">" }
        return script
    }
    func printVal() -> String {
        return scriptVal(parens: true, session: true, expand: true)
    }

    func scriptVal(parens: Bool,
                   session: Bool,
                   expand: Bool) -> String {

        var script = (" " + Tr3EdgeDef.scriptEdgeFlag(edgeFlags)).with(trailing: " ")

        if let tern = ternVal {
            script += tern.scriptVal(parens: parens, session: session)
        }
        else {
            if pathVals.pathList.count > 1 { script += "(" }
            for path in pathVals.pathList {
                script.spacePlus(path)
                if let val = pathVals.pathDict[path] {
                    script += val?.scriptVal(expand: expand) ?? ""
                }
            }
            if pathVals.pathList.count > 1 { script += ")" }
        }
        return script.with(trailing: " ")
    }
}
