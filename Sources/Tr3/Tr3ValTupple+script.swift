//
//  File.swift
//  
//
//  Created by warren on 12/26/20.
//

import Par

extension Tr3ValTuple {

    override func printVal() -> String {
        var script = "("
        for num in scalars {
            script += script.parenSpace() + "\(num)"
        }
        return script.with(trailing: ")")
    }
    func scriptNamed() -> String? {
        if names.isEmpty { return nil }
        
        var script = ""
        var delim = ""

        for name in names {

            script += delim + name

            if let scalar = named[name] {

                script += " " + scalar.dumpVal(parens: false)
            }
            delim = valFlags.contains(.comma) ? ", " : " "
        }
        return script
    }

    func scriptExprs() -> String? {
        if exprs.isEmpty { return nil }

        var script = ""
        var delim = ""
        for expr in exprs.values {
            script += delim;  delim = ", "
            script += expr.script()
        }
        return script
    }
    func scriptScalars() -> String? {
        if scalars.isEmpty { return nil }

        var script = ""
        var delim = ""
        for scalar in scalars {
            script += delim; delim = " "
            script += scalar.dumpVal(parens: false)
        }
        return script
    }

    override func scriptVal(parens: Bool) -> String  {
        if let val = scriptExprs() ?? scriptNamed() ?? scriptScalars() {
            return parens ? "(\(val))" : val
        }
        return ""
    }

    override func dumpVal(parens: Bool, session: Bool = false) -> String  {
        if session {
            return scriptVal(parens: true)
        } else {
            return scriptVal(parens: parens)
        }
    }

}
