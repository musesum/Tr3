
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
    
    override init () {
        super.init()
    }
    
    override init(with tr3Val: Tr3Val) {
        super.init(with: tr3Val)

        if let v = tr3Val as? Tr3Exprs {
            
            valFlags = v.valFlags
            for (name,val) in v.nameScalar {
                nameScalar[name] = Tr3ValScalar(with: val)
            }
            for name in v.names {
                names.append(name)
            }
            for expr in v.exprs {
                exprs.append(expr.copy())
            }
        }
        else {
            valFlags = .scalar // use default values
        }
    }
    
    convenience init(with p: CGPoint) {
        self.init()
        valFlags.insert([.exprNames, .exprScalars])
        let x = Tr3ValScalar(num: Float(p.x))
        let y = Tr3ValScalar(num: Float(p.y))
        names = ContiguousArray<ExprName>(["x","y"])
        scalars = ContiguousArray<Tr3ValScalar>([x,y])
        nameScalar = ["x": x, "y": y]
    }
    
    convenience init(pairs: [(ExprName,Float)]) {
        self.init()
        valFlags.insert([.exprNames, .exprScalars])
        names = ContiguousArray<ExprName>()
        nameScalar = [ExprName: Tr3ValScalar]()
        
        for (name,val) in pairs {
            let scalar = Tr3ValScalar(num: val)
            names.append(name)
            nameScalar[name] = scalar
            scalars.append(scalar)
        }
    }

    convenience init(names: [ExprName]) {
        self.init()
        valFlags.insert([.exprNames])
        self.names = ContiguousArray<ExprName>()
        for name in names {
            self.names.append(name)
        }
    }
    convenience init(values: [Float]) {
        self.init()
        valFlags.insert([.exprScalars])
        scalars = ContiguousArray<Tr3ValScalar>()
        for val in values {
            scalars.append(Tr3ValScalar(num: val))
        }
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
    
    func addPath(_ parItem: ParItem) {
        if let value = parItem.nextPars.first?.value {
            addName(value)
        }
    }
    
    func addScalars(_ scalarStrs: [String]) {
        valFlags.insert(.exprScalars)
        for str in scalarStrs {
            scalars.append(Tr3ValScalar(with: str))
        }
    }
    func addScalar(_ scalar: Tr3ValScalar) {
        valFlags.insert(.exprScalars)
        scalars.append(scalar)
    }

    func addOper(_ opStr: String?) {
        guard let opStr = opStr?.without(trailing: " ") else { return }
        let name = names.last ?? "_"

        if let exprOp = Tr3ExprOp(rawValue: opStr) {
            if let lastExpr = exprs.last {
                lastExpr.addExprOp(exprOp)
            } else {
                let expr = Tr3Expr(name: name, exprOp: exprOp)
                exprs.append(expr)
            }
        }
    }

    func addName(_ name: String?) {
        guard let name = name else { return }
        valFlags.insert([.exprs, .exprNames])

        if names.last == name { // O(n^2)
            return
        }
        else {
            names.append(name)
        }
    }
    /// parse scalar with `0` in `0..1`
    func addScalar(_ num: Float? = nil ) -> Tr3ValScalar {
        valFlags.insert([.exprs, .exprScalars])
        var scalar: Tr3ValScalar
        if let num = num {
            scalar = Tr3ValScalar(num: num)
        } else {
            scalar = Tr3ValScalar()
        }

        if let expr = exprs.last {
            expr.addNext(scalar)
        }
        // pure scalars `(1 2 3)`
        else {
            scalars.append(scalar)
        }
        return scalar
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
    public override func setVal(_ any: Any?,_ options: Any? = nil) {

        func setFloat(_ v: Float) {
            valFlags.insert(.exprScalars)
            scalars[0].num = v
        }
        func setPoint(_ p: CGPoint) {

            func addPoint() {
                valFlags.insert(.exprNames)
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
                if let frScalar = from.nameScalar[expr.name],
                   let toScalar = nameScalar[expr.name] {

                    if expr.isEligible(frScalar.num, toScalar) == false {
                        return false 
                    }
                } else {
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

        func setExprs(_ from: Tr3Exprs) {
            if names.isEmpty {
                if exprs.isEmpty {
                    // a(1..2, 3..4) << b(5..6 = 5, 7..8 = 8) ⟹ a(1, 4)
                    let count = min(scalars.count, from.scalars.count)
                    if count < 1 { return }
                    for i in 0..<scalars.count {
                        let toScalar = scalars[scalars.startIndex + i]
                        let frScalar = from.scalars[from.scalars.startIndex + i]
                        toScalar.setVal(frScalar)
                    }
                } else if isEligible(from) {
                    // a(+) << b(1, 2, 3) ⟹ a(+ = 6)
                } else {
                    // a(> 2) << b(1) fails
                    return
                }

            } else if exprs.isEmpty {
                // a(x _, y _) _
                for name in names {
                    if let toScalar = nameScalar[name] {
                        // a(x 1, y 2) ...
                        if let frScalar = from.nameScalar[name] {
                            // a(x 1, y 2) << b(x 1, y 2) ⟹ a(x 1, y 2)
                            toScalar.setVal(frScalar)
                        } else {
                            // a(x 1, y 2) << b(1, 2) ⟹ a(x 1, y 2)
                        }
                    } else {
                        // a(x, y) << b(x 1, y 2) ⟹ a(x 1, y 2)
                    }
                }
            } else {
                // a(x + _, y + _) _
                if from.names.isEmpty {
                    // a(x + _, y + _ ) << b(3, 4)
                    return // from must have a name
                } else if isEligible(from) {
                    // a(x + _, y + _) << b(x 3, y 4)
                    for expr in exprs {
                        if let exprScalar = nameScalar[expr.name] {
                            if let fromScalar = from.nameScalar[expr.name] {
                                // a(x + 1, y + 2) << b(x 3, y 4) ⟹ a(x 4 , y 6)
                                expr.eval(from: fromScalar, expr: exprScalar)
                            } else {
                                // a(x + 1, y + 2) << b(x, y) ⟹ a(4 , y 6)
                            }
                        } else {
                            // a(x, y) << b(x 1, y 2) ⟹ a(x 1, y 2)
                        }
                    }
                } else {
                    return
                }
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
            default: print("*** mismatched setVal(\(any))")
            }
        }
    }
}
