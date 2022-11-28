
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
    public var nameAny: OrderedDictionary<String,Any> = [:]

    /// `t(x/2, y/2) << u(x 1, y 2)` ⟹ `t(x 0.5, y 1.0)` // after u fires
    public var exprs = ContiguousArray<Tr3Expr>()

    /// set of all ops in exprs
    var opSet = Set<Tr3ExprOp>()

    /// return _0, _1, ... for anonymous values
    var anonKey: String {
        String(format: "_%i", nameAny.keys.count)
    }

    override init(_ tr3: Tr3? = nil) {
        super.init(tr3)
    }
    override init(with tr3Val: Tr3Val) {
        super.init(with: tr3Val)

        if let v = tr3Val as? Tr3Exprs {
            
            valFlags = v.valFlags
            for (name, val) in v.nameAny {
                nameAny[name] = val
            }
            for expr in v.exprs {
                exprs.append(Tr3Expr(from: expr))
            }
            opSet = v.opSet
        }
    }
    init(_ tr3: Tr3? = nil, point: CGPoint) {
        super.init(tr3)
        addPoint(point)
    }
    public init(_ tr3: Tr3? = nil, nameNums: [(String, Double)]) {
        super.init(tr3)
        opSet = Set<Tr3ExprOp>([.name,.num])

        for (name, num) in nameNums {
            if exprs.count > 0 {
                addOpStr(",")
            }
            addNameNum(name, num)
        }
    }
    override func copy() -> Tr3Exprs {
        let newTr3Exprs = Tr3Exprs(with: self)
        return newTr3Exprs
    }

    // MARK: - Get
    public override func getVal() -> Any {

        if let cgPoint = getCGPoint() { return cgPoint }
        if let nums = getNums() { return nums }

        if nameAny.values.count > 0 { return nameAny.values }
        print("*** unknown expression values")
        return []
    }
    /// used for metal shader in Sky
    public func getValNums() -> [Double] { 
        var nums = [Double]()
        for value in nameAny.values {
            switch value {
                case let v as Tr3ValScalar: nums.append(Double(v.now))
                case let v as CGFloat: nums.append(Double(v))
                case let v as Float: nums.append(Double(v))
                case let v as Double: nums.append(v)
                default: nums.append(0)
            }
        }
        if nums.isEmpty {
            print("*** unknown expression values")
        }
        return nums
    }
    // MARK: - Set
    public override func setVal(_ any: Any?, _ opts: Tr3SetOptions? = nil) -> Bool {

        if let any {
            switch any {
                case let v as Float:    return setDouble(Double(v))
                case let v as CGFloat:  return setDouble(Double(v))
                case let v as Double:   return setDouble(Double(v))
                case let v as CGPoint:  return setPoint(v)
                case let v as Tr3Exprs: return setExprs(from: v)
                case let (n,v) as (String,Float): return setNamed(n, Double(v))
                case let (n,v) as (String,Double): return setNamed(n, Double(v))
                case let (n,v) as (String,CGFloat): return setNamed(n, Double(v))
                default: print("🚫 mismatched setVal(\(any))")
            }
        }
        return false
    }
    func setNows() { // was setDefaults
        if nameAny.count > 0 {
            for value in nameAny.values {
                if let scalar = value as? Tr3ValScalar {
                    scalar.setNow()
                }
            }
        }
    }
    func setNamed(_ name: String, _ value: Double) -> Bool {
        if let scalar = nameAny[name] as? Tr3ValScalar {
            scalar.setVal(value) //??? 
        } else {
            nameAny[name] = Tr3ValScalar(tr3, num: value)
        }
        addFlag(.now)
        return true
    }

    public override func printVal() -> String {
        var script = "("
        for num in nameAny.values {
            script.spacePlus("\(num)")
        }
        return script.with(trailing: ")")
    }
    public override func scriptVal(_ scriptFlags: Tr3ScriptFlags) -> String {

        var script = ""
        script = scriptExprs(scriptFlags)
        return script.isEmpty ? "" : scriptFlags.contains(.parens) ? "(\(script))" : script
    }
   override public func hasDelta() -> Bool {
        for val in nameAny.values {
            if let val = val as? Tr3Val, val.hasDelta() {
                return true
            }
        }
        return false
    }
}
