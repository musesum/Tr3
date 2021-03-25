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
            script += delim; delim = hasComma ? ", " : " "
            script += expr.script()
        }
        return script
    }
    func scriptScalars() -> String {
        var script = ""
        var delim = ""
        for scalar in scalars {
            script += delim; delim = hasComma ? ", " : " "
            script += scalar.dumpVal(parens: false)
        }
        return script
    }

    override func scriptVal(parens: Bool) -> String  {
        var script = ""
        var delim = ""
        if names.isEmpty {
            script = scriptScalars()
        } else {
            for name in names {
                script += delim
                delim = hasComma ? ", " : " "
                if let expr = exprs[name] {
                    script += expr.script()
                } else if let scalar = named[name] {
                    script += name + " " + scalar.scriptVal(parens: false)
                } else {
                    script += name
                }
            }
        }
        return script.isEmpty ? "" : parens ? "(\(script))" : script
    }

    override func dumpVal(parens: Bool, session: Bool = false) -> String  {
        if session == false {
            return scriptVal(parens: parens)
        }
        var val = ""
        var delim = ""
        if names.isEmpty {
            val = scriptScalars()
        } else {
            for name in names {
                if let scalar = named[name] {
                    val += delim + name + String(format: " %g", scalar.num)
                    delim = hasComma ? ", " : " "
                }
            }
        }
        return val.isEmpty ? "" : parens ? "(\(val))" : val
    }
}
