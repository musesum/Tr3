//
//  File.swift
//  
//
//  Created by warren on 4/13/21.
//

import Foundation

extension Tr3ValScalar {

    override func printVal() -> String {
        return String(now)
    }

    override func scriptVal(parens: Bool = false,
                            session: Bool,
                            expand: Bool = true) -> String  {
        if session {
            if valFlags.contains(.now) ||
                valFlags.contains(.lit) {

                let numStr = String(format: "%g", now)
                return parens ? "(\(numStr))" : numStr
            }
            return ""
        }
        else {
            var script = parens ? "(" : ""
            if valFlags.rawValue == 0   { return "" }
            if valFlags.contains(.min)  { script += String(format: "%g", min) }
            if valFlags.contains(.thru) { script += "…" /* option+`;` */}
            if valFlags.contains(.modu) { script += "%" }
            if valFlags.contains(.max)  { script += String(format: "%g", max) }
            if valFlags.contains(.dflt) { script += String(format: "=%g", dflt) }
            if valFlags.contains(.now)  { script += String(format: ":%g", now) }
            else if valFlags.contains(.lit) { script += String(format: " %g", now) }

            script += parens ? ")" : ""
            return script
        }
    }
}

