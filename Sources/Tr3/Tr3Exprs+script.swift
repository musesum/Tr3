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
    func scriptNames(session: Bool) -> String {
        var script = ""
        var delim = ""
        for name in names {
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
                if expr.exprOp != .none { continue }
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

    func scriptScalars(session: Bool) -> String {
        var script = ""
        var delim = ""
        for scalar in scalars {
            script += delim; delim = ", "
            script += scalar.dumpVal(parens: false, session: session)
        }
        return script
    }

    override func scriptVal(parens: Bool) -> String  {
        var script = ""
        switch lastParse {
            case .expr:         script = scriptExprs(session: false)

            case .nameScalar,
                 .names:        script = scriptNames(session: false)

            case .scalars:      script = scriptScalars(session: false)

            default: break
        }
        return script.isEmpty ? "" : parens ? "(\(script))" : script
    }

    override func dumpVal(parens: Bool, session: Bool = false) -> String  {
        var script = ""

        switch lastParse {
            case .expr:         script = scriptExprs(session: session)

            case .nameScalar,
                 .names:        script = scriptNames(session: session)

            case .scalars:      script = scriptScalars(session: session)

            default: break
        }
        return script.isEmpty ? "" : parens ? "(\(script))" : script
    }
}
