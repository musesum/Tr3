//
//  Tr3EdgeDefs+script.swift
//  Par iOS
//
//  Created by warren on 4/5/19.
//

import Foundation

extension Tr3EdgeDef {

    
    static func scriptEdgeFlag(_ flags:Tr3EdgeFlags, _ active:Bool = true) -> String {

        var script =  flags.contains(.input) ? "<" : ""
        
        if      flags.contains(.nada)    { script += "!" }
        else if flags.contains(.find)    { script += ":" }
        else if flags.contains(.ternary) { script += "?" }
        else                             { script += active ? "-" : "╌" }

        if flags.contains(.output)       { script += ">"} 
        return script
    }

    public func scriptVal() -> String {

        var script = ""
        script += Tr3EdgeDef.scriptEdgeFlag(edgeFlags)

        if let tern = defVal as? Tr3ValTern {
            script += tern.scriptVal(prefix:"")
        }
        else {
            if defPaths.count > 1   { script += "(" }
            for defPath in defPaths { script += script.parenSpace() + defPath }
            if defPaths.count > 1   { script += ")" }
            script += defVal?.scriptVal(prefix:"") ?? ""
        }
        return script.with(trailing:" ")
    }

    public func dumpEdge(_ tr3:Tr3) -> String {

        var script = ""
        script += Tr3EdgeDef.scriptEdgeFlag(edgeFlags)

        if let tern = defVal as? Tr3ValTern {
            script += tern.dumpVal(prefix:"")
        }
        else {
            script += edges.count > 1 ? "(" : ""
            for edge in edges {
                script += edge.dumpVal(tr3) + " "
            }
            //if script.last == " " { script.removeLast() }
            script += edges.count > 1 ? ")" : ""
        }
        return script.with(trailing:" ")
    }


}


