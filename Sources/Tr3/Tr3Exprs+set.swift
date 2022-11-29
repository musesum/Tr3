// Tr3Exprs+set
//
//  Created by warren on 8/21/22.
//

import Foundation

extension Tr3Exprs { // + set

    func setDouble(_ v: Double) -> Bool {
        if let n = nameAny["val"] as? Tr3ValScalar {
            _ = n.setVal(v)
            n.addFlag(.now)
        }
        else {
            nameAny["val"] = Tr3ValScalar(tr3, num: v) //TODO: remove this kludge for DeepMenu
        }
        return true
    }

    func setPoint(_ p: CGPoint) -> Bool {
        if exprs.isEmpty {
            // create a new expr list
            addPoint(p)
            return true
        }
        let copy = copy()
        copy.tr3 = nil
        copy.injectNameNum("x", Double(p.x))
        copy.injectNameNum("y", Double(p.y))
        return setExprs(frExprs: copy)
    }

    /// evaluate expression
    ///
    ///     // example             setters after a!  script(session=true)
    ///     a(x 1, y 2)         // ("x",1), ("y",2)  a(x 1, y 2)
    ///     b(x + y)      << a  // ("x",3)           b(x 3)
    ///     c(z: x + y)   << a  // ("z",3)           c(z 3)
    ///     d(: x + y)    << a  // ("_0",3)          d(3)
    ///     e(x: x + y)   << a  // ("x",3)           e(3)
    ///     f(x: y, y: x) << a  // ("x",2), ("t",1)  f(x 2, y 1)
    ///     g(x, y)       << a  // ("x",1), ("y",2)  g(x 1, y 2)
    ///     h(x - 1, y*2) << a  // ("x",0), ("y",4)  h(x 0, y 4)
    ///     i(x + y, z:y) << a  // ("x",3), ("z",4)  i(x 3, z 2)
    ///     j(x < 1, y)   << a  // abort all setters j(x, y)
    ///     k(x < 2, y)   << a  // ("x",1), ("y",2)  k(x 2, y 3)
    ///     l(count: + 1) << a  // ("count",1)       l(1), l(2) ... l(∞)
    ///     m(+1)         << a  // ("_0",1)          m(1), m(2) ... m(∞)
    ///     n(1 + 2)
    ///     p(++)
    ///
    ///  -note: failed conditional will abort all setters and should abort activate edges
    ///
    public typealias ExprSetters = ContiguousArray<(String,Any?)>
    func evalExprs() -> Bool {

        var mySetters = ExprSetters()
        var toVal: Any?
        var myVal: Any?
        var myName: String?
        var opNow = Tr3ExprOp.none

        for i in 0...exprs.count {

            if i==exprs.count {
                endParameter()
                setSetters(mySetters)
                return true
            }
            let expr = exprs[i]

            switch expr.op {

                case .quote, .scalar, .num:     if !exprLiteral() { return false }

                case    .EQ, .LE, .GE, .LT,
                        .GT, .In, .add, .sub,
                        .muy,.divi,.div,.mod,
                        .assign:                opNow = expr.op

                case .path, .name:              if !exprName() { return false }

                case .comma:                    endParameter()

                case .assign, .none:            break
            }

            /// match from and to parameters
            func exprName() -> Bool {

                if let name = expr.val as? String {

                    if myName == nil {
                        myName = name
                        myVal = nameAny[name]
                    }
                    if let frVal = nameAny[name] {
                        if opNow == .assign,
                           (frVal as? String) == "",
                           let val = tr3?.val as? Tr3ValScalar {
                            toVal = val.now
                        } else if opNow != .none {
                            toVal = expr.evaluate(toVal ?? myVal, frVal, opNow)
                            opNow = .none
                            return toVal != nil
                        } else {
                            toVal = frVal
                        }
                    }
                }
                return true
            }

            /// evaluate numbers and strings, return false if should abort expression
            func exprLiteral() -> Bool  {
                let frVal = toVal ?? myVal
                toVal = expr.evaluate(expr.val, frVal, opNow)
                return toVal != nil
            }
        }
        return true

        /// reset current values after comma
        func endParameter() {
            if let myName, let toVal {
                mySetters.append((myName,toVal))
            }
            // reset for next expr parameter
            opNow = .none
            myName = nil
            toVal = nil
        }
    }
    ///execute all deferrred setters
    func setSetters(_ mySetters: ExprSetters) {
        for (name,val) in mySetters {
            switch val {
                case let val as Tr3ValScalar:
                    if let toVal = nameAny[name] as? Tr3Val {
                        /// `x` in `a(x 1) << b`
                        _ = toVal.setVal(val)
                    } else {
                        /// `x` in `a(x) << b`
                        nameAny[name] = val.copy()
                    }
                case let val as Double:

                    nameAny[name] = Tr3ValScalar(num: val)

                case let val as String:
                    if let toVal = nameAny[name]  as? Tr3Val {
                        if !val.isEmpty {
                            /// `x` in `a(x in 2…4) << b, `b(x 3)`
                            _ = toVal.setVal(val)
                        }
                    }
                default : break
            }
        }
    }
    func setExprs(frExprs: Tr3Exprs) -> Bool {

        var mySetters = ExprSetters()
        var toVal: Any?
        var myVal: Any?
        var myName: String?
        var opNow = Tr3ExprOp.none

        for i in 0...exprs.count {

            if i==exprs.count {
                endParameter()
                setSetters(mySetters)
                return true
            }
            let expr = exprs[i]

            switch expr.op {

                case .quote, .scalar, .num:     if !exprLiteral() { return false }

                case    .EQ, .LE, .GE, .LT,
                        .GT, .In, .add, .sub,
                        .muy,.divi,.div,.mod:   opNow = expr.op

                case .path, .name:              if !exprName() { return false }

                case .comma:                    endParameter()

                case .assign, .none:            break
            }

            /// match from and to parameters
            func exprName() -> Bool {
                
                if let name = expr.val as? String {

                    if myName == nil {
                        myName = name
                        myVal = nameAny[name]
                    }
                    if let frVal = frExprs.nameAny[name] {
                        if opNow != .none {
                            toVal = expr.evaluate(toVal ?? myVal, frVal, opNow)
                            opNow = .none
                            return toVal != nil
                        } else {
                            toVal = frVal
                        }
                    }
                }
                return true
            }

            /// evaluate numbers and strings, return false if should abort expression
            func exprLiteral() -> Bool  {
                let frVal = toVal ?? myVal
                toVal = expr.evaluate(expr.val, frVal, opNow)
                return toVal != nil
            }
        }
        return true

        /// reset current values after comma
        func endParameter() {
            if let myName, let toVal {
                mySetters.append((myName,toVal))
            }
            // reset for next expr parameter
            opNow = .none
            myName = nil
            toVal = nil
        }
    }
}
