//  Tr3ValScalar.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import QuartzCore

public class Tr3ValScalar: Tr3Val {

    // default scalar value is (0…1 = 1)
    public var num  = Float(0) // current value
    public var min  = Float(0) // minimum value
    public var max  = Float(1) // maximum value, inclusive for thru
    public var dflt = Float(0) // default value

    override init(_ tr3: Tr3) {
        super.init(tr3)
    }
    init(_ tr3: Tr3, with str: String) {
        super.init(tr3)
        let val = Float(str) ?? Float.nan
        addNum(val)
    }
    init(_ tr3: Tr3, num: Float) {
        super.init(tr3)
        valFlags = .num
        self.min = fmin(num, 0.0)
        self.max = fmax(num, 1.0)
        self.num = num
    }
   
    init (with scalar: Tr3ValScalar) {
        super.init(scalar.tr3)
        valFlags = scalar.valFlags // use default values
        num  = scalar.num
        min  = scalar.min
        max  = scalar.max
        dflt = scalar.dflt
    }
    override func copy() -> Tr3Val {
        let newTr3ValScalar = Tr3ValScalar(with: self)
        return newTr3ValScalar
    }

    func addNum(_ n: Float) {

        if valFlags.contains(.thru) {
            if valFlags.contains(.max) {
                valFlags.insert(.dflt)
                dflt = n
                num = n
            } else if valFlags.contains(.min) {
                valFlags.insert(.max)
                max = n
            } else {
                valFlags.insert(.min)
                min = n
            }
        } else if valFlags.contains(.modu) {
            if valFlags.contains(.max) {
                valFlags.insert(.dflt)
                dflt = n
                num = n
            } else {
                valFlags.insert(.max)
                max = n
            }
        } else {
            valFlags.insert(.num)
            num = n
        }
    }
    
    func setDefault() {
        if valFlags.contains(.modu) {
            num = 0
        }
        if valFlags.contains(.dflt) {
            num = dflt
        } else if valFlags.contains(.min), num < min {
            num = min
        } else if valFlags.contains(.max), num > max {
           num = max
        } else if valFlags.intersection([.num, .min, .max, .dflt]) == [] {
            valFlags.insert([.num, .dflt])
            dflt = num 
        }
    }
   
    static func |= (lhs: Tr3ValScalar, rhs: Tr3ValScalar) {
        
        let mergeFlags = lhs.valFlags.rawValue |  rhs.valFlags.rawValue
        lhs.valFlags = Tr3ValFlags(rawValue: mergeFlags)
        if rhs.valFlags.contains(.min) { lhs.min = rhs.min }
        if rhs.valFlags.contains(.max) { lhs.max = rhs.max }
        if rhs.valFlags.contains(.num) { lhs.num = rhs.num }
    }

    public static func == (lhs: Tr3ValScalar, rhs: Tr3ValScalar) -> Bool { return lhs.num == rhs.num }
    public static func >= (lhs: Tr3ValScalar, rhs: Tr3ValScalar) -> Bool { return lhs.num >= rhs.num }
    public static func >  (lhs: Tr3ValScalar, rhs: Tr3ValScalar) -> Bool { return lhs.num >  rhs.num }
    public static func <= (lhs: Tr3ValScalar, rhs: Tr3ValScalar) -> Bool { return lhs.num <= rhs.num }
    public static func <  (lhs: Tr3ValScalar, rhs: Tr3ValScalar) -> Bool { return lhs.num <  rhs.num }
    public static func != (lhs: Tr3ValScalar, rhs: Tr3ValScalar) -> Bool { return lhs.num != rhs.num }

    public func inRange(of test: Float) -> Bool {

        if valFlags.contains(.modu), test > max { return false }
        if valFlags.contains(.min),  test < min { return false }
        if valFlags.contains(.max),  test > max { return false }
        return true
    }


    public override func setVal(_ val: Any?,
                                _ options: Tr3SetOptions? = nil) {

        if let val = val {
            switch val {
                case let v as Tr3ValScalar : setFromScalar(v)
                case let v as Float        : setFromFloat(v)
                case let v as CGFloat      : setFromFloat(v)
                case let v as Double       : setFromFloat(v)
                case let v as Int          : setFromFloat(v)
                default: print("🚫 setVal unknown type for: from")
            }
        }

        func setFromScalar(_ v: Tr3ValScalar) {

            if   valFlags.contains(.thru),
                 v.valFlags.contains(.thru) {

                let toMax   = max
                let frMax   = v.max
                let toRange = toMax -   min
                let frRange = frMax - v.min
                num = (v.num - v.min) * (toRange / frRange) + min
            }
            else if valFlags.contains(.modu) {

                min = 0
                max = fmaxf(1, max)
                num = fmodf(v.num, max)
            }
            else {
                num = v.num
                setInRange()
            }
        }
        func setFromFloat(_ v: Int)      { num = Float(v) ; setInRange() }
        func setFromFloat(_ v: Double)   { num = Float(v) ; setInRange() }
        func setFromFloat(_ v: CGFloat)  { num = Float(v) ; setInRange() }
        func setFromFloat(_ v: Float)    { num = v        ; setInRange() }

        func setInRange() {

            if valFlags.contains(.modu) { num = fmodf(num, max) }
            if valFlags.contains(.min), num < min { num = min }
            if valFlags.contains(.max), num > max { num = max }
        }
    }
    public override func getVal() -> Any {
        return num
    }
}
