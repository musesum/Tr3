
//  Tr3Exprs.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import QuartzCore
import Par

typealias ExprName = String

public class Tr3Exprs: Tr3Val {

    /// `t(x 1, y 2)` ⟹ `["x": 1, "y": 2]`
    var nameScalar = [ExprName: Tr3ValScalar]()

    /// `t(x, y)` ⟹ `["x", "y"]`
    var names = ContiguousArray<ExprName>()

    /// `t(1, 2)` ⟹ `[1, 2]`
    var scalars = ContiguousArray<Tr3ValScalar>() 

    /// `t(x/2, y/2) << u(x 1, y 2)` ⟹ `u(x 0.5, y 1.0)` // after t fires
    var exprs = ContiguousArray<Tr3Expr>()

    var options = Tr3ExprOptions(rawValue: 0)
    
    override init() {
        super.init()
    }
    override init(with tr3Val: Tr3Val) {
        super.init(with: tr3Val)

        if let v = tr3Val as? Tr3Exprs {
            
            valFlags = v.valFlags
            for (name, val) in v.nameScalar {
                nameScalar[name] = Tr3ValScalar(with: val)
                options.insert([.name, .scalar])
            }
            for name in v.names {
                names.append(name)
                options.insert(.name)
            }
            for expr in v.exprs {
                exprs.append(expr.copy())
                options.insert(.expr)
            }
        }
        else {
            valFlags = .scalar // use default values
        }
    }
    convenience init(with p: CGPoint) {
        self.init()
        valFlags.insert([.names, .nameScalars])
        let x = Tr3ValScalar(num: Float(p.x))
        let y = Tr3ValScalar(num: Float(p.y))
        names = ContiguousArray<ExprName>(["x","y"])
        scalars = ContiguousArray<Tr3ValScalar>([x, y])
        nameScalar = ["x": x, "y": y]
        options.insert([.name, .scalar])
    }
    convenience init(pairs: [(ExprName, Float)]) {
        self.init()
        valFlags.insert([.names, .nameScalars])
        names = ContiguousArray<ExprName>()
        nameScalar = [ExprName: Tr3ValScalar]()
        
        for (name, val) in pairs {
            let scalar = Tr3ValScalar(num: val)
            names.append(name)
            nameScalar[name] = scalar
            scalars.append(scalar)
        }
        options.insert([.name, .scalar])
    }
    convenience init(names: [ExprName]) {
        self.init()
        valFlags.insert([.names])
        self.names = ContiguousArray<ExprName>()
        for name in names {
            self.names.append(name)
        }
        options.insert(.name)
    }
    convenience init(values: [Float]) {
        self.init()
        valFlags.insert([.nameScalars])
        scalars = ContiguousArray<Tr3ValScalar>()
        for val in values {
            scalars.append(Tr3ValScalar(num: val))
        }
        options.insert(.scalar)
    }
    override func copy() -> Tr3Exprs {
        let newTr3Exprs = Tr3Exprs(with: self)
        return newTr3Exprs
    }
    
    public static func < (lhs: Tr3Exprs, rhs: Tr3Exprs) -> Bool {
        
        if rhs.scalars.isEmpty ||
            rhs.scalars.count != lhs.scalars.count {
            return false
        }
        var lsum = Float(0)
        var rsum = Float(0)
        for val in lhs.scalars { lsum += val.num * val.num }
        for val in rhs.scalars { rsum += val.num * val.num }
        return lsum < rsum
    }

    func addExpr() {
        let expr = Tr3Expr()
        exprs.append(expr)
        valFlags.insert(.exprs)
        options.insert(.expr)
    }
    func addPath(_ parItem: ParItem) {
        if let name = parItem.nextPars.first?.value {
            addName(name)
        }
    }
    func addScalars(_ scalarStrs: [String]) {
        valFlags.insert(.nameScalars)
        for str in scalarStrs {
            scalars.append(Tr3ValScalar(with: str))
        }
    }
    func addScalar(_ scalar: Tr3ValScalar) {

        if let expr = exprs.last {
            if expr.options.contains(.rvalue) {
                let expr = Tr3Expr()
                exprs.append(expr)
                expr.addExprScalar(scalar)
            } else {
                expr.addExprScalar(scalar)
            }
            if let lastName = names.last,
                expr.exprOp == .none {
                nameScalar[lastName] = scalar
            }
        }
        options.insert(.scalar)
    }
    /// parse scalar with `0` in `0..1`
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
            options.insert(.op)
        }
    }
    func addName(_ name: String?) {
        guard let name = name else { return }
        if !nameScalar.keys.contains(name) {
            names.append(name)
        }
        nameScalar[name] = Tr3ValScalar() // placeholder
        
        if let expr = exprs.last {
            expr.addExprName(name)
        }
        valFlags.insert([.exprs, .names, .scalar, .nameScalars])
        options.insert(.name)
    }
    func addNum(_ num: Float) {
        if let name = names.last,
           let scalar = nameScalar[name] {
            scalar.addNum(num)
        } else {
            _ = addScalar(num)
        }
    }
    func setDefaults() {
        if nameScalar.count > 0 {
            for scalar in nameScalar.values {
                scalar.setDefault()
            }
        } else {
            for scalar in scalars {
                scalar.setDefault()
            }
        }
    }
    /** set this Tuple from another tuple.
     Expressions can act as a filter `x < 1` which may reject the candidate

     or change value `x/2`
     */
    public override func setVal(_ any: Any?, _ opts: Any? = nil) {

        func setFloat(_ v: Float) {
            valFlags.insert(.nameScalars)
            scalars[0].num = v
        }
        func setPoint(_ p: CGPoint) {

            func addPoint() {
                valFlags.insert(.names)
                if let x = nameScalar["x"] {
                    x.setVal(p.x)
                    x.addFlag(.num)
                }
                else {
                    names.append("x")
                    nameScalar["x"] = Tr3ValScalar(num: Float(p.x))
                }
                if let y = nameScalar["y"] {
                    y.setVal(p.y)
                    y.addFlag(.num)
                }
                else {
                    names.append("y")
                    nameScalar["y"] = Tr3ValScalar(num: Float(p.y))
                }
            }
            // begin -------------------------------
            if exprs.isEmpty { return addPoint() }
            let exprs = Tr3Exprs(with: p)
            setExprs(exprs)
        }
        func isEligible(_ from: Tr3Exprs) -> Bool {
            if exprs.isEmpty {
                return true
            }
            for expr in exprs {
                let name = expr.name
                if let frScalar = from.nameScalar[name],
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
        // f7(x in 2..4, x 1..2, y in 3..5, y 2..3) ⟹ (x 1, y 2) // no z
        // f8(x in 2..4, x 1..2, y in 3..5, y 2..3, x + y) ⟹ (x 1, y 2, _ 3)
        // f9(_ , _ , _ ) ⟹

        //   0 1  2 3  4 5
        // a(x 2, y 3, z 4) >> f
        //   0 1  3  4  5 6  7  8 9 10 11 12 13 14
        // f(x in 2..4, x 1..2, y in 3..5, y 2..3) ⟹ (x 1, y 2) // no z
        // f(x in 2..4, y in 3..5, x 1..2, y 2..3) ⟹ (x 1, y 2) // no z
        //a.0 :: f.0 f.5
        //	a.1 in f.3..f.4 ?  a.1 .. f.5..f.6

        func setScalars(to: ContiguousArray<Tr3ValScalar>, fr: ContiguousArray<Tr3ValScalar>) {

            // a(1..2, 3..4) << b(5..6 = 5, 7..8 = 8) ⟹ a(1, 4)
            let count = min(to.count, fr.count)
            if count < 1 { return }
            for i in 0..<scalars.count {
                let toScalar = to[to.startIndex + i]
                let frScalar = fr[fr.startIndex + i]
                toScalar.setVal(frScalar)
            }
        }
        func setNamed(to: Tr3Exprs, fr: Tr3Exprs) {
            // a(x _, y _) _
            for name in to.names {
                if let toScalar = to.nameScalar[name] {
                    // a(x 1, y 2) ...
                    if let frScalar = fr.nameScalar[name] {
                        // a(x 1, y 2) << b(x 1, y 2) ⟹ a(x 1, y 2)
                        toScalar.setVal(frScalar)
                    } else {
                        // a(x 1, y 2) << b(1, 2) ⟹ a(x 1, y 2)
                    }
                } else {
                    // a(x, y) << b(x 1, y 2) ⟹ a(x 1, y 2)
                }
            }
        }
        func setExprs(to: Tr3Exprs, fr: Tr3Exprs) {
            if isEligible(fr) {
                // a(x + _, y + _) << b(x _, y _)
                for toExpr in to.exprs {
                    let name = toExpr.name
                    if let frScalar = fr.nameScalar[name] {

                        // a(x in 2..4, y in 3..5) >> b b(x 1..2, y 2..3)
                        if let inScalar = toExpr.evalIsIn(from: frScalar) {
                            to.nameScalar[name] = inScalar
                        }
                        // a(x + 1, y + 2) << b(x 3, y 4) ⟹ a(x 4 , y 6)
                        else if let rScalar = toExpr.eval(frScalar: frScalar) ,
                                let toScalar = to.nameScalar[name] {
                            
                            toScalar.setVal(rScalar)
                        }
                    } else {
                        // a(x + 1, y + 2) << b(x, y) ⟹ a(x + 1, y + 2)
                        // skip
                    }
                }
            }
        }

        func setExprs(_ fr: Tr3Exprs) {
            if self.options.contains(.expr) {
                setExprs(to: self, fr: fr)
            } else if self.options.contains(.name) {
                setNamed(to: self, fr: fr)
            } else if self.options.contains(.scalar) {
               setScalars(to: scalars, fr: fr.scalars)
            }
        }
        // begin -------------------------

        if let any = any {
            switch any {
                case let v as Float:    setFloat(v)
                case let v as CGFloat:  setFloat(Float(v))
                case let v as Double:   setFloat(Float(v))
                case let v as CGPoint:  setPoint(v)
                case let v as Tr3Exprs: setExprs(v)
                default: print("🚫 mismatched setVal(\(any))")
            }
        }
    }
}
