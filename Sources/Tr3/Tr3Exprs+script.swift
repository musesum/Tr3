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
        for num in nameAny.values {
            script.spacePlus("\(num)")
        }
        return script.with(trailing: ")")
    }

    private func scriptNames(session: Bool) -> String {
        var script = ""
        var delim = ""
        for (name,val) in nameAny {

            script.spacePlus(delim) ; delim = ", "
            if name.first != "_" {
                script.spacePlus(name)
            }
            
            switch val {
                case let v as Tr3ValScalar:

                    script.spacePlus(v.scriptVal(session: session))

                case let v as String:

                    script.spacePlus(v)

                default: break
            }
        }
        return script
    }

    private func scriptExprs(session: Bool) -> String {
        var script = ""
        if session {

            var lastNamePath = ""
            var assigned = false
            var literals = false
            var hasOp = false

            for i in 0 ... exprs.count {
                if i == exprs.count {
                    /// finish `y` in `a(x,y)`
                    scriptPassthrough()
                    break
                }
                let expr = exprs[i]
                switch expr.op {

                    case .comma:
                        /// finish `x` in `a(x,y)`
                        scriptPassthrough()
                        scriptExpr()
                        // next pararmeter
                        literals = false
                        assigned = false
                        hasOp = false

                    case .name, .path:
                        /// skip `x` and `y` in `a(sum: x + y)`
                        if assigned || hasOp { continue }
                        /// add `x` and `y` in `a (x 1, y 2)`
                        lastNamePath = expr.val as? String ?? "??"
                        scriptExpr()

                    case .quote, .scalar, .num:
                        if hasOp { continue }
                        scriptExpr()
                        literals = true

                    case .EQ, .LE, .GE, .LT, .GT, .In, .Add, .Sub, .Muy, .Div, .Mod:
                        hasOp = true

                    case .assign:
                        assigned = true

                    case .none: break
                }

                func scriptExpr() {
                    let s = expr.script(session: session)
                    script.spacePlus(s)
                }
                /// kludge to accomadate `a(x, y) << b, b(x 0, y 0) -- see testExpr0()
                func scriptPassthrough() {
                    if !literals {
                        if lastNamePath.count > 0,
                           let val = nameAny[lastNamePath] as? Tr3Val {
                            let s = val.scriptVal(parens: false, session: session)
                            script.spacePlus(s)
                            lastNamePath = ""
                        }
                    }
                }
            }
        } else {
            for expr in exprs {
                script.spacePlus(expr.script(session: session))
            }
        }
        return script
    }

    override func scriptVal(parens: Bool = true,
                            session: Bool = false,
                            expand: Bool = false) -> String  {
        var script = ""

        script = scriptExprs(session: session)

        return script.isEmpty ? "" : parens ? "(\(script))" : script
    }
}
