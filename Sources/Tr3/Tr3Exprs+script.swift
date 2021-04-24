//
//  File.swift
//  
//
//  Created by warren on 12/26/20.
//

import Par

extension Tr3Exprs {

    override func printVal() -> String {
        var script = "("
        for num in scalars {
            script += script.parenSpace() + "\(num)"
        }
        return script.with(trailing: ")")
    }
    func scriptNames() -> String {
        var script = ""
        var delim = ""
        for name in names {
            script += delim + name; delim = ", "
            if let scalar = nameScalar[name] {
                script += " " + scalar.dumpVal(parens: false)
            }
        }
        return script
    }

    func scriptExprs() -> String {
        var script = ""
        var delim = ""
        for expr in exprs {
            script += delim; delim = ", "
            script += expr.script()
        }
        return script
    }
    func scriptScalars() -> String {
        var script = ""
        var delim = ""
        for scalar in scalars {
            script += delim; delim = ", "
            script += scalar.dumpVal(parens: false)
        }
        return script
    }

    override func scriptVal(parens: Bool) -> String  {
        var script = ""
        if      names.isEmpty { script = scriptScalars() }
        else if exprs.isEmpty { script = scriptNames() }
        else                  { script = scriptExprs() }

        return script.isEmpty ? "" : parens ? "(\(script))" : script
    }

    override func dumpVal(parens: Bool, session: Bool = false) -> String  {
        var script = ""
        if session == false { return scriptVal(parens: parens) }
        if names.isEmpty    { script = scriptScalars() }
        else                { script = scriptNames() }
        return script.isEmpty ? "" : parens ? "(\(script))" : script
    }
}
