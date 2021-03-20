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
    func scriptScalars() -> String {
        var script = ""
        var delim = ""
        for scalar in scalars {
            script += delim; delim = " "
            script += scalar.dumpVal(parens: false)
        }
        return script
    }

    override func scriptVal(parens: Bool) -> String  {
        var val = ""
        var delim = ""
        if names.isEmpty {
            val = scriptScalars()
        } else {
            for name in names {
                val += delim
                 delim = hasComma ? ", " : " "
                if let expr = exprs[name] {
                    val += expr.script()
                } else if let scalar = named[name] {
                    val += name + " " + scalar.scriptVal(parens: false)
                } else {
                    val += name
                }
            }
        }
        return val.isEmpty ? "" : parens ? "(\(val))" : val
    }

    override func dumpVal(parens: Bool, session: Bool = false) -> String  {
        if session {
            return scriptVal(parens: true)
        } else {
            return scriptVal(parens: parens)
        }
    }

}
