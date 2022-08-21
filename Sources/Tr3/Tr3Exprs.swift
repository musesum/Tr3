
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

    /// `t(x/2, y/2) << u(x 1, y 2)` ⟹ `t(x 0.5, y 1.0)` // after u fires
    public var exprs = ContiguousArray<Tr3Expr>()

    override init() {
        super.init()
    }
    override init(with tr3Val: Tr3Val) {
        super.init(with: tr3Val)

        if let v = tr3Val as? Tr3Exprs {
            
            valFlags = v.valFlags
            for (name, val) in v.nameAny {
                nameAny[name] = val
            }
            for expr in v.exprs {
                exprs.append(expr.copy())
            }
        }
    }
    convenience init(point: CGPoint) {
        self.init()
        valFlags.insert([.names, .num])
        let x = Tr3ValScalar(num: Float(point.x))
        let y = Tr3ValScalar(num: Float(point.y))
        nameAny = ["x": x, "y": y]
    }
    convenience init(nameFloats: [(String, Float)]) {
        self.init()
        valFlags.insert([.names, .num]) 
        nameAny = [:]

        for (name, val) in nameFloats {
            let scalar = Tr3ValScalar(num: val)
            nameAny[name] = scalar
        }
    }
    override func copy() -> Tr3Exprs {
        let newTr3Exprs = Tr3Exprs(with: self)
        return newTr3Exprs
    }

    // MARK: - Get
    public override func getVal() -> Any {

        if let cgPoint = getCGPoint() { return cgPoint }
        if let floats = getFloats() { return floats }

        if nameAny.values.count > 0 { return nameAny.values }
        print("*** unknown expression values")
        return []
    }
    // used for metal shader
    public func getValFloats() -> [Float] {
        var floats = [Float]()

        for value in nameAny.values {
            switch value {
                case let v as Tr3ValScalar: floats.append(Float(v.num))
                case let v as CGFloat: floats.append(Float(v))
                case let v as Float: floats.append(v)
                default: print("*** skipping expression value \(value)")
            }
        }
        if floats.isEmpty {
            print("*** unknown expression values")
        }
        return floats
    }
    // MARK: - Set
    public override func setVal(_ any: Any?, _ opts: Tr3SetOptions? = nil) {

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
    func setDefaults() {
        if nameAny.count > 0 {
            for value in nameAny.values {
                if let scalar = value as? Tr3ValScalar {
                    scalar.setDefault()
                }
            }
        }
    }

}
