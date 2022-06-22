//
//  File.swift
//  
//
//  Created by warren on 4/13/21.
//

import Foundation

extension Tr3ValScalar {

    override func printVal() -> String {
        return String(num)
    }

    override func scriptVal(parens: Bool,
                            session: Bool,
                            expand: Bool) -> String  {
        if session {
            let numStr = String(format: "%g", num)
            return parens ? "(\(numStr))" : numStr
        }
        else {
            var script = parens ? "(" : ""
            if valFlags.rawValue == 0   { return "" }
            if valFlags.contains(.min)  { script += String(format: "%g", min) }
            if valFlags.contains(.thru) { script += "…" }
            if valFlags.contains(.modu) { script += "%" }
            if valFlags.contains(.max)  { script += String(format: "%g", max) }
            if valFlags.intersection([.dflt,.num]) != [] {
                if valFlags.contains([.min,.max]) { script += " = " }
                script += String(format: "%g", num)
            }
            script += parens ? ")" : ""
            return script
        }
    }
}

