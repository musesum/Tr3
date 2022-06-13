//
//  Tr3Exprs.swift
//  
//
//  Created by warren on 12/26/20.
//

import Par

extension Tr3Exprs {

    override func printVal() -> String {
        var script = "("
        for num in nameScalar.values { 
            script += script.parenSpace() + "\(num)"
        }
        return script.with(trailing: ")")
    }

    func scriptNames(session: Bool) -> String {
        var script = ""
        var delim = ""
        for name in nameScalar.keys {
            script += delim + name; delim = ", "
            if let scalar = nameScalar[name] {
                script += " " + scalar.dumpVal(parens: false, session: session)
            }
        }
        return script
    }

    func scriptExprs(session: Bool) -> String {
        var script = ""
        var delim = ""
        if session {
            for expr in exprs {
                if expr.exprOperator != .none { continue }
                script += delim; delim = ", "
                script += expr.script(session: session)
            }
        } else {
            for expr in exprs {
                script += delim; delim = ", "
                script += expr.script(session: session)
            }
        }
        return script
    }

    override func scriptVal(parens: Bool) -> String  {
        var script = ""
        if exprOptions.contains(.expr) {
            script = scriptExprs(session: false)
        } else if exprOptions.contains(.name) {
            script = scriptNames(session: false)
        }
        return script.isEmpty ? "" : parens ? "(\(script))" : script
    }

    override func dumpVal(parens: Bool, session: Bool = false) -> String  {
        var script = ""
        if session {
            script = scriptNames(session: session)
        } else if exprOptions.contains(.expr) {
            script = scriptExprs(session: session)
        } else if exprOptions.contains(.name) {
            script = scriptNames(session: session)
        }
        return script.isEmpty ? "" : parens ? "(\(script))" : script 
    }
}
