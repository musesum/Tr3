
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
            hasComma = v.hasComma
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
            named[name] = scalar
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
        hasComma = true
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
    /** set this Tuple from another tuple.
     Expressions can act as a filter `x < 1` which may reject the candidate

     or change value `x/2`

     */
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
        func isEligible(_ from: Tr3ValTuple) -> Bool {
            for (name,expr) in exprs {
                if let frVal = from.named[name],
                   let toVal = named[name] {

                    if expr.isEligible(named, toVal, frVal) == false {
                        return false
                    }
                } else {
                    return false
                }
            }
            return true
        }
        func setTuple(_ from: Tr3ValTuple) {
            if names.isEmpty {
                if scalars.count >= from.scalars.count {
                    for i in 0..<scalars.count {
                        let toScalar = scalars[scalars.startIndex + i]
                        let frScalar = from.scalars[from.scalars.startIndex + i]
                        toScalar.setVal(frScalar)
                    }
                }
            } else if isEligible(from) {
                for name in from.names {
                    if let frVal = from.named[name] {
                        if let toVal = named[name] {
                            if let expr = exprs[name] {
                                expr.eval(named, toVal, frVal)
                            } else {
                                valFlags.insert([.tupNames, .tupScalars])
                                toVal.setVal(frVal)
                            }
                        } else {
                            valFlags.insert([.tupNames, .tupScalars])
                            named[name] = Tr3ValScalar(with: frVal) 
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
