//
//  File.swift
//  
//
//  Created by warren on 4/13/21.
//

import Foundation

extension Tr3ValScalar {

    override func scriptVal(parens: Bool) -> String  {
        var script = parens ? "(" : ""
        if valFlags.rawValue == 0   { return "" }
        if valFlags.contains(.min)  { script += String(format: "%g", min) }
        if valFlags.contains(.thru) { script += ".." }
        if valFlags.contains(.modu) { script += "%" }
        if valFlags.contains(.max)  { script += String(format: "%g", max) }
        if valFlags.intersection([.dflt,.num]) != [] {
            if valFlags.contains([.min,.max]) { script += " = " }
            script += String(format: "%g",num)
        }
        script += parens ? ")" : ""
        return script
    }
    override func dumpVal(parens: Bool, session: Bool = false) -> String  {
        if session {
            let script = "(" + String(format: "%g", num)
            return script.with(trailing: ")")
        }
        else {
            return scriptVal(parens: parens)
        }
    }
}

