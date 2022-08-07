
//  Tr3Exprs.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import QuartzCore
import Collections
import Foundation
import Par

public class Tr3Exprs: Tr3Val {

    /// `t(x 1, y 2)` ⟹ `["x": 1, "y": 2]`
    var nameAny: OrderedDictionary<String,Any> = [:]

    /// `t(x/2, y/2) << u(x 1, y 2)` ⟹ `u(x 0.5, y 1.0)` // after t fires
    public var exprs = ContiguousArray<Tr3Expr>()

    var exprOptions = Tr3ExprOptions(rawValue: 0)
    
    override init() {
        super.init()
    }
    override init(with tr3Val: Tr3Val) {
        super.init(with: tr3Val)

        if let v = tr3Val as? Tr3Exprs {
            
            valFlags = v.valFlags
            for (name, val) in v.nameAny {
                nameAny[name] = val
                exprOptions.insert([.name, .scalar])
            }
            for expr in v.exprs {
                exprs.append(expr.copy())
                exprOptions.insert(.expr)
            }
        }
        else {
            valFlags = .scalar // use default values
        }
    }

    convenience init(point: CGPoint) {
        self.init()
        valFlags.insert([.names, .nameScalars])
        let x = Tr3ValScalar(num: Float(point.x))
        let y = Tr3ValScalar(num: Float(point.y))
        nameAny = ["x": x, "y": y]
        exprOptions.insert([.name, .scalar])
    }

    convenience init(nameFloats: [(String, Float)]) {
        self.init()
        valFlags.insert([.names, .nameScalars])
        nameAny = [:]

        for (name, val) in nameFloats {
            let scalar = Tr3ValScalar(num: val)
            nameAny[name] = scalar
        }
        exprOptions.insert([.name, .scalar])
    }

    override func copy() -> Tr3Exprs {
        let newTr3Exprs = Tr3Exprs(with: self)
        return newTr3Exprs
    }

    func addExpr() {
        let expr = Tr3Expr()
        exprs.append(expr)
        valFlags.insert(.exprs)
        exprOptions.insert(.expr)
    }
    func addPath(_ parItem: ParItem) {
        if let name = parItem.nextPars.first?.value {
            addName(name)
        }
    }
    func addScalar(_ scalar: Tr3ValScalar) {

        if let expr = exprs.last {
            if expr.exprOptions.contains(.rvalue) {
                let expr = Tr3Expr()
                exprs.append(expr)
                expr.addExprScalar(scalar)
            } else {
                expr.addExprScalar(scalar)
            }
            if let lastName = nameAny.keys.last,
                expr.exprOperator == .none {
                nameAny[lastName] = scalar
            }
        }
        exprOptions.insert(.scalar)
    }
    
    /// parse scalar with `0` in `0…1`
    func addScalar(_ num: Float? = nil ) -> Tr3ValScalar {
        var scalar: Tr3ValScalar
        if let num = num {
            scalar = Tr3ValScalar(num: num)
        } else {
            scalar = Tr3ValScalar()
        }
        addScalar(scalar)
        return scalar
    }
    func addOper(_ opStr: String?) {
        if let opStr = opStr?.without(trailing: " ")  {
            exprs.last?.addOpStr(opStr)
            exprOptions.insert(.oper)
        }
    }
    func addQuote(_ quote: String?) {
        if let quote = quote?.without(trailing: " ")  {
            exprs.last?.addQuote(quote)
            exprOptions.insert(.quote)
            if let name = nameAny.keys.last {
                nameAny[name] = quote
            }
        }
    }
    func addName(_ name: String?) {
        guard let name = name else { return }
        if !nameAny.keys.contains(name) {
            nameAny[name] = Tr3ValScalar() //placeholder
        }
        if let expr = exprs.last {
            expr.addExprName(name)
        }
        valFlags.insert([.exprs, .names, .scalar, .nameScalars])
        exprOptions.insert(.name)
    }
    func addNum(_ num: Float) {
        if let name = nameAny.keys.last,
           let scalar = nameAny[name] as? Tr3ValScalar {
            scalar.addNum(num)
        } else {
            _ = addScalar(num)
        }
    }
    func setDefaults() {
        if nameAny.count > 0 {
            for value in nameAny.values {
                if let scalar = value as? Tr3ValScalar {
                    scalar.setDefault()
                }
            }
        }
    }
    /** set this Tuple from another tuple.
     Expressions can act as a filter `x < 1` which may reject the candidate

     or change value `x/2`
     */
    public override func setVal(_ any: Any?, _ opts: Tr3SetOptions? = nil) {

        func setFloat(_ v: Float) {
            valFlags.insert(.names)
            if let n = nameAny["val"] as? Tr3ValScalar {
                n.setVal(v)
                n.addFlag(.num)
            }
            else {
                nameAny["val"] = Tr3ValScalar(num: v) //TODO: remove this kludge for DeepMenu
            }
        }

        func setPoint(_ p: CGPoint) {

            func addPoint() {
                valFlags.insert(.names)
                if let n = nameAny["x"] as? Tr3ValScalar {
                    n.setVal(p.x)
                    n.addFlag(.num)
                }
                else {
                    nameAny["x"] = Tr3ValScalar(num: Float(p.x))
                }
                if let n = nameAny["y"] as? Tr3ValScalar {
                    n.setVal(p.y)
                    n.addFlag(.num)
                }
                else {
                    nameAny["y"] = Tr3ValScalar(num: Float(p.y))
                }
            }
            // begin -------------------------------
            if exprs.isEmpty { return addPoint() }
            let exprs = Tr3Exprs(point: p)
            setExprs(to: self, fr: exprs)
        }
        func isEligible(_ from: Tr3Exprs) -> Bool {
            if exprs.isEmpty {
                return true
            }
            for expr in exprs {
                let name = expr.name
                if let frScalar = from.nameAny[name] as? Tr3ValScalar ,
                   expr.isEligible(num: frScalar.num) == false {
                        return false
                }
            }
            return true
        }

        // a(x 2, y 3, z 4) >> f
        // f1(x<y) ⟹ (x 2, y 3, z 4)
        // f2(x>y) ⟹ ()
        // f3(x+y) ⟹ (x 5)
        // f4(+)   ⟹ (_ 9)
        // f5(*)   ⟹ (_ 24)
        // f6(x*10, x/10) ⟹ (x 20, x 0.5)
        // f7(x in 2…4, x 1…2, y in 3…5, y 2…3) ⟹ (x 1, y 2) // no z
        // f8(x in 2…4, x 1…2, y in 3…5, y 2…3, x + y) ⟹ (x 1, y 2, _ 3)
        // f9(_ , _ , _ ) ⟹

        //   0 1  2 3  4 5
        // a(x 2, y 3, z 4) >> f
        //   0 1  3  4  5 6  7  8 9 10 11 12 13 14
        // f(x in 2…4, x 1…2, y in 3…5, y 2…3) ⟹ (x 1, y 2) // no z
        // f(x in 2…4, y in 3…5, x 1…2, y 2…3) ⟹ (x 1, y 2) // no z
        //a.0 :: f.0 f.5
        //	a.1 in f.3..f.4 ?  a.1 … f.5..f.6
        func setExprs(to: Tr3Exprs, fr: Tr3Exprs) {
            if isEligible(fr) {
                // a(x + _, y + _) << b(x _, y _)
                for toExpr in to.exprs {
                    let name = toExpr.name
                    if let frScalar = fr.nameAny[name] as? Tr3ValScalar {

                        // a(x in 2…4, y in 3…5) >> b b(x 1…2, y 2…3)
                        if let inScalar = toExpr.evalIsIn(from: frScalar ) {
                            to.nameAny[name] = inScalar
                        }
                        // a(x + 1, y + 2) << b(x 3, y 4) ⟹ a(x 4 , y 6)
                        else if let rScalar = toExpr.eval(frScalar: frScalar) ,
                                let toScalar = to.nameAny[name] as? Tr3ValScalar {
                            
                            toScalar.setVal(rScalar)
                        }
                    } else {
                        // a(x + 1, y + 2) << b(x, y) ⟹ a(x + 1, y + 2)
                        // skip
                    }
                }
            }
        }

        func setNamed(_ name: String, _ value: Float) {
            if let scalar = nameAny[name] as? Tr3ValScalar {
                scalar.num = value
            } else {
                nameAny[name] = Tr3ValScalar(num: value)
            }
            addFlag(.num)
        }

        // begin -------------------------

        if let any = any {
            switch any {
                case let v as Float:    setFloat(v)
                case let v as CGFloat:  setFloat(Float(v))
                case let v as Double:   setFloat(Float(v))
                case let v as CGPoint:  setPoint(v)
                case let v as Tr3Exprs: setExprs(to: self, fr: v)
                case let (n,v) as (String,Float): setNamed(n, v)
                case let (n,v) as (String,CGFloat): setNamed(n, Float(v))
                default: print("🚫 mismatched setVal(\(any))")
            }
        }
    }
    public override func getVal() -> Any {

        func getCGPoint() -> CGPoint? {
            if nameAny.count == 2,
               let x = nameAny["x"] as? Tr3ValScalar,
               let y = nameAny["y"] as? Tr3ValScalar {
                let xNum = Double(x.num)
                let yNum = Double(y.num)

                return CGPoint(x: xNum, y: yNum)
            }
            return nil
        }

        func getFloats() -> [Float]? {
            var floats = [Float]()
            for value in nameAny.values {
                switch value {
                    case let v as Tr3ValScalar: floats.append(Float(v.num))
                    case let v as CGFloat: floats.append(Float(v))
                    case let v as Float: floats.append(v)
                    default: return nil
                }
            }
            return floats.isEmpty ? nil : floats
        }

        if let cgPoint = getCGPoint() { return cgPoint }
        if let floats = getFloats() { return floats }

        if nameAny.values.count > 0 { return nameAny.values }
        print("*** unknown expression values")
        return []
    }
    
}
