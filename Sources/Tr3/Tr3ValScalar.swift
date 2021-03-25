//  Tr3ValScalar.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import QuartzCore

public class Tr3ValScalar: Tr3Val {

    // default scalar value is (0..1 = 1)
    var num  = Float(0) // current value
    var min  = Float(0) // minimum value
    var max  = Float(1) // maximum value, inclusive for thru
    var dflt = Float(0) // current value

    override init() {
        super.init()
    }
    init(with str: String) {
        super.init()
        let val = Float(str) ?? Float.nan
        addNum(val)
    }
    init(num: Float) {
        super.init()
        valFlags = .num
        self.min = fmin(num, 0.0)
        self.max = fmax(num, 1.0)
        self.num = num
    }
   
    init (with scalar: Tr3ValScalar) {
        super.init()
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

    func addNum(_ val_: Float) {

        if valFlags.contains(.thru) {
            if valFlags.contains(.max) {
                valFlags.insert(.dflt)
                dflt = val_
                num = val_
            } else if valFlags.contains(.min) {
                valFlags.insert(.max)
                max = val_
            } else {
                valFlags.insert(.min)
                min = val_
            }
        } else if valFlags.contains(.modu) {
            if valFlags.contains(.max) {
                valFlags.insert(.dflt)
                dflt = val_
                num = val_
            } else {
                valFlags.insert(.max)
                max = val_
            }
        } else {
            valFlags.insert(.num)
            num = val_
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
        } else if valFlags.intersection([.num,.min,.max,.dflt]) == [] {
            valFlags.insert([.num, .dflt])
            dflt = num 
        }
    }
    
    override func printVal() -> String {
        return String(num)
    }

    override func scriptVal(parens: Bool) -> String  {
        var script = parens ? "(" : ""
        if valFlags.rawValue == 0   { return "" }
        if valFlags.contains(.min)  { script += String(format: "%g", min) }
        if valFlags.contains(.thru) { script += ".." }
        if valFlags.contains(.modu) { script += "%" }
        if valFlags.contains(.max)  { script += String(format: "%g", max) }
        if valFlags.intersection([.dflt,.num]) != [] {
            if valFlags.contains([.min,.max]) { script += " = " }
            script += String(format: "%g",num)
        }
        if valFlags.contains(.comma) {
            script += ", "
        }
        script += parens ? ")" : ""
        return script
    }
    override func dumpVal(parens: Bool, session: Bool = false) -> String  {
        if session {
            let script = "(" + String(format: "%g", num)
            return script.with(trailing: ")")
        }
        else {
            return scriptVal(parens: parens)
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

        if valFlags.contains(.modu),test > max { return false }
        if valFlags.contains(.min), test < min { return false }
        if valFlags.contains(.max), test > max { return false }
        return true
    }

    func setInRange() {

        if valFlags.contains(.modu) { num = fmodf(num, max) }
        if valFlags.contains(.min), num < min { num = min }
        if valFlags.contains(.max), num > max { num = max }
    }

    func setRangeFrom01(_ val_: Float) {

        if valFlags.contains(.modu) { num = fmod(val_,fmax(1,max)) }
        else                        { num = val_ * (max - min) + min }
    }

    func rangeTo01() -> Float {
        return valFlags.contains(.modu)
            ? fmod(num,max) / fmaxf(1, max-1)
            : (num - min) / fmaxf(1, max - min)
    }

    func changeRangeFrom01(_ val_: Float) -> Bool {

        let oldNum = num
        setRangeFrom01(val_)
        return (num != oldNum)
    }

    func setFromScalar(_ v: Tr3ValScalar) {

        if valFlags.contains(.thru),
           v.valFlags.contains(.thru) {

            let toMax   = max
            let frMax   = v.max
            let toRange = toMax -   min
            let frRange = frMax - v.min
            num = (v.num - v.min) * (toRange / frRange) + min
        }
        else if valFlags.contains(.modu) {

            min = 0
            max = fmaxf(1,max)
            num = fmodf(v.num,max)
        }
        else {
            num = v.num
            setInRange()
        }
    }

    public override func setVal(_ from: Any?, _ options: Any? = nil) {

        // from contains normalized values 0...1
        let zero1 = (options as? Tr3SetOptions ?? []).contains(.zero1)

        if let val = from {
            switch val {
            case let v as Tr3ValScalar: setFromScalar(v)
            case let v as Float:   zero1 ? setFloat01(v) : setFloat(v)
            case let v as CGFloat: zero1 ? setFloat01(v) : setFloat(v)
            case let v as Double:  zero1 ? setFloat01(v) : setFloat(v)
            case let v as Int:     zero1 ? setFloat01(v) : setFloat(v)
            default: print("*** mismatched setVal(\(val))")
            }
        }
    }

    func setFloat(_ v: Int)      { num = Float(v) ; setInRange() }
    func setFloat(_ v: Double)   { num = Float(v) ; setInRange() }
    func setFloat(_ v: CGFloat)  { num = Float(v) ; setInRange() }
    func setFloat(_ v: Float)    { num = v        ; setInRange() }

    func setFloat01(_ v: Int)    { setRangeFrom01(Float(v)) }
    func setFloat01(_ v: Double) { setRangeFrom01(Float(v)) }
    func setFloat01(_ v: CGFloat){ setRangeFrom01(Float(v)) }
    func setFloat01(_ v: Float)  { setRangeFrom01(v) }

    //    func increment()            { num += 1 ; setInRange() }
    //    func decrement()            { num -= 1 ; setInRange() }
}
