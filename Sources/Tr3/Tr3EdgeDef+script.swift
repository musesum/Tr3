//  Tr3EdgeDefs+script.swift
//
//  Created by warren on 4/5/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

extension Tr3EdgeDef {

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
        else if flags.contains(.exclude) { script += "!" }
        else if flags.contains(.find)    { script += ":" }
        else if flags.contains(.ternary) { script += "⋯" }
        else if flags.contains(.copyat)  { script += "@" }
        else if active == false          { script += "╌" }

        if flags.contains(.output)       { script += ">" }
        return script
    }

    public func scriptVal() -> String {

        var script = (" " + Tr3EdgeDef.scriptEdgeFlag(edgeFlags)).with(trailing: " ")

        if let tern = ternVal {
            script += tern.scriptVal()
        }
        else {
            if pathVals.pathList.count > 1 { script += "(" }
            for path in pathVals.pathList {
                script += script.parenSpace() + path
                if let val = pathVals.pathDict[path] {
                    script += val?.scriptVal() ?? ""
                }
            }
            if pathVals.pathList.count > 1 { script += ")" }
        }
        return script.with(trailing:" ")
    }

    public func dumpEdge(_ tr3: Tr3) -> String {

        var script = ""
        script += Tr3EdgeDef.scriptEdgeFlag(edgeFlags).with(trailing: " ")

        if let tern = ternVal {
            script += tern.dumpVal()
        }
        else {
            script += edges.count > 1 ? "(" : ""
            for edge in edges.values {
                script += edge.dumpVal(tr3) + " "
            }
            script += edges.count > 1 ? ")" : ""
        }
        return script.with(trailing:" ")
    }


}


