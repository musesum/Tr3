
//  Tr3ValTuple.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import QuartzCore
import Par

typealias TupName = String

public class Tr3ValTuple: Tr3Val {

    /// ["x": TupValScalar(1) and ["y": TupValScalar(2) for `t(x 1 y 2)`
    var named = [TupName: Tr3ValScalar]()

    /// `x` and `y` in `t(x 1 y 2)`
    var names = ContiguousArray<TupName>()

    /// for raw tuples `a(1 2 3)`
    var scalars = ContiguousArray<Tr3ValScalar>()

    /// `t(x/2 y/2) << u(x 2 y 4)` result in `t(x 1 y 2)` after u fires
    var exprs = [TupName: Tr3ValTupExpr]() /// expressions only evaluated on lvalue

    var hasComma = false
    
    override init () {
        super.init()
    }
    
    override init(with tr3Val: Tr3Val) {
        super.init(with: tr3Val)

        if let v = tr3Val as? Tr3ValTuple {
            
            valFlags = v.valFlags
            named = v.named
            names = v.names
            exprs = v.exprs
        }
        else {
            valFlags = .scalar // use default values
        }
    }
    
    convenience init(with p: CGPoint) {
        self.init()
        valFlags.insert([.tupNames, .tupScalars])
        let x = Tr3ValScalar(with: Float(p.x))
        let y = Tr3ValScalar(with: Float(p.y))
        names = ContiguousArray<TupName>(["x","y"])
        named = [TupName: Tr3ValScalar]()
        named["x"] = x
        named["y"] = y
    }
    
    convenience init(pairs: [(TupName,Float)]) {
        self.init()
        valFlags.insert([.tupNames, .tupScalars])
        names = ContiguousArray<TupName>()
        named = [TupName: Tr3ValScalar]()
        
        for (name,val) in pairs {
            let scalar = Tr3ValScalar(with: val)
            names.append(name)
            named[name] = scalar
        }
    }

    convenience init(names: [TupName]) {
        self.init()
        valFlags.insert([.tupNames])
        self.names = ContiguousArray<TupName>()
        for name in names {
            self.names.append(name)
        }
    }
    convenience init(values: [Float]) {
        self.init()
        valFlags.insert([.tupScalars])
        scalars = ContiguousArray<Tr3ValScalar>()
        for val in values {
            scalars.append(Tr3ValScalar(with: val))
        }
    }
    override func copy() -> Tr3ValTuple {
        let newTr3ValTuple = Tr3ValTuple(with: self)
        return newTr3ValTuple
    }
    
    public static func < (lhs: Tr3ValTuple, rhs: Tr3ValTuple) -> Bool {
        
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
        valFlags.insert(.tupScalars)
        for str in scalarStrs {
            scalars.append(Tr3ValScalar(with: str))
        }
    }
    func addScalar(_ scalar: Tr3ValScalar) {
        valFlags.insert(.tupScalars)
        scalars.append(scalar)
    }

    /// top off scalars with proper number of scalars
    func insureScalars(count insureCount: Int) {
        if scalars.count < insureCount {
            for _ in scalars.count ... insureCount {
                scalars.append(Tr3ValScalar())
            }
        }
    }

    func addOper(_ opStr: String?) {
        if let opStr = opStr,
           let tupOp = Tr3ValTupOp(rawValue: opStr),
           let name = names.last {

            if let last = exprs[name] {
                last.addTupOp(tupOp)
            } else {
                exprs[name] = Tr3ValTupExpr(name: name, tupOp: tupOp)
            }
        } else {
            print("unexpected op: \(opStr ?? "nil")")
        }
    }
    func addName(_ name_: String?) {
        guard let name = name_ else { return }
        valFlags.insert([.tuple, .tupNames])

        if names.last == name { // O(n^2)
            return
        }
        else {
            names.append(name)
        }
    }
    func addScalar(_ num: Float? = nil ) -> Tr3ValScalar {
        let num = num ?? 0
        valFlags.insert([.tuple, .tupScalars])
        let scalar = Tr3ValScalar(with: num)
        if let name = names.last {
            // expression `(x < 1, y < 2)`
            if let expr = exprs[name] {
                expr.addNext(scalar)
            }
            // named scalars: `(x 1, y 2, z 3)`
            else {
                named[name] = scalar
            }
        }
        // pure scalars `(1 2 3)`
        else {
            scalars.append(scalar)
        }
        return scalar
    }
    func addNum(_ num: Float) {
        if let name = names.last,
           let scalar = named[name] {
            scalar.addNum(num)
        } else {
            _ = addScalar(num)
        }
    }
    override func addComma() {
        if let name = names.last,
           let scalar = named[name] {
            scalar.addComma()
        } else if let scalar = scalars.last {
            scalar.addComma()
        }
    }
    func setDefaults() {
        if named.count > 0 {
            for scalar in named.values {
                scalar.setDefault()
            }
        } else {
            for scalar in scalars {
                scalar.setDefault()
            }
        }
    }
    
    public override func setVal(_ any: Any?,_ options: Any? = nil) {

        func setFloat(_ v: Float) {
            valFlags.insert(.tupScalars)
            insureScalars(count: 1)
            scalars[0].num = v
        }
        func setPoint(_ v: CGPoint) {

            if let x = named["x"] {
                x.setVal(v.x)
            }
            else {
                names.append("x")
                named["x"] = Tr3ValScalar(with: Float(v.x)) }

            if let y = named["y"] {
                y.setVal(v.y)
            }
            else {
                names.append("y")
                named["y"] = Tr3ValScalar(with: Float(v.y))
            }
        }
        func copyFrom(_ from: Tr3ValTuple) {
            valFlags = from.valFlags
            if from.scalars.count > 0 {
                valFlags.insert([.tuple, .tupScalars])
                for scalar in from.scalars {
                    scalars.append(Tr3ValScalar(with: scalar))
                }
            }
            if from.named.count > 0 {
                valFlags.insert([.tuple, .tupNames])
                named = [TupName: Tr3ValScalar]()
                for (name, scalar) in from.named {
                    named[name] = scalar
                }
            }
            if from.exprs.count > 0 {
                valFlags.insert([.tuple, .tupExprs])
                for (name,expr) in from.exprs {
                    exprs[name] = Tr3ValTupExpr(with: expr)
                }
            }
        }
        func setTuple(_ from: Tr3ValTuple) {

            if exprs.count > 0 {
                for expr in exprs.values {
                    expr.eval(self, from)
                }
            }
            else if scalars.count > 0 {
                copyFrom(from)
            }
            else if names.count > 0 {

                for name in names {
                    if let frScalar = from.named[name] {
                        if let toScalar = named[name] {
                            toScalar.setVal(frScalar)
                        }
                        else {
                            named[name] = frScalar
                        }
                    }
                }
            }
        }
        // begin -------------------------
        
        if let any = any {
            switch any {
            case let v as Float:       setFloat(v)
            case let v as CGFloat:     setFloat(Float(v))
            case let v as Double:      setFloat(Float(v))
            case let v as CGPoint:     setPoint(v)
            case let v as Tr3ValTuple: setTuple(v)
            default: print("*** mismatched setVal(\(any))")
            }
        }
    }
}
