//  Tr3ValScalar.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

import QuartzCore

public class Tr3ValScalar: Tr3Val {

    // default scalar value is (0...1=1)
    var num  = Float(0) // current value
    var min  = Float(0) // minimum value
    var max  = Float(1) // maximum value, inclusive for thru

    override init() {
        super.init()
    }
    init(with str: String) {
        super.init()
        let val = Float(str) ?? Float.nan
        addDflt(val)
    }
    init(with num_: Float) {
        super.init()
        min = fmin(num_, 0.0)
        max = fmax(num_, 1.0)
        num = num_
    }
    init (with tr3Val: Tr3ValScalar) {

        super.init(with: tr3Val)

        valFlags = tr3Val.valFlags // use default values
        num  = tr3Val.num
        min  = tr3Val.min
        max  = tr3Val.max
    }
    override func copy() -> Tr3Val {
        let newTr3ValScalar = Tr3ValScalar(with: self)
        return newTr3ValScalar
    }

    func addMin (_ val_: Float) { valFlags.insert(.min );  min = val_; num = val_}
    func addMax (_ val_: Float) { valFlags.insert(.max );  max = val_ }
    func addDflt(_ val_: Float) { valFlags.insert(.dflt);  num = val_ }

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

        if valFlags.contains(.dflt) {
            if valFlags.contains([.min,.max]) { script += " = " }
            script += String(format: "%g",num)
        } else if valFlags.contains(.min), num != min {
            script += " = " + String(format: "%g",num)
        } else if num != min {
            script += " = " + String(format: "%g",num)
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
        if rhs.valFlags.contains(.min )  { lhs.min  = rhs.min }
        if rhs.valFlags.contains(.max )  { lhs.max  = rhs.max }
        if rhs.valFlags.contains(.num )  { lhs.num  = rhs.num }
    }

    public static func == (lhs: Tr3ValScalar, rhs: Tr3ValScalar) -> Bool { return lhs.num == rhs.num }
    public static func >= (lhs: Tr3ValScalar, rhs: Tr3ValScalar) -> Bool { return lhs.num >= rhs.num }
    public static func >  (lhs: Tr3ValScalar, rhs: Tr3ValScalar) -> Bool { return lhs.num >  rhs.num }
    public static func <= (lhs: Tr3ValScalar, rhs: Tr3ValScalar) -> Bool { return lhs.num <= rhs.num }
    public static func <  (lhs: Tr3ValScalar, rhs: Tr3ValScalar) -> Bool { return lhs.num <  rhs.num }
    public static func != (lhs: Tr3ValScalar, rhs: Tr3ValScalar) -> Bool { return lhs.num != rhs.num }

    func withinRange() {

        if valFlags.contains(.modu) { num = fmodf(num, max) }
        if valFlags.contains(.min), num < min { num = min }
        if valFlags.contains(.max) {
            if valFlags.contains(.thru), num > max   { num = max }
        }
    }

    func setRangeFrom01(_ val_: Float) {

        if      valFlags.contains(.modu) { num = fmod(val_,fmax(1,max)) }
        else                             { num = val_ * (max - min)     + min }
    }

    func rangeTo01() -> Float {

        if      valFlags.contains(.modu) { return fmod(num,max) / fmaxf(1, max-1) }
        else if valFlags.contains(.thru) { return (num - min) / fmaxf(1, max - min) }
        else                             { return (num - min) / fmaxf(1, max - min - 1) }
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
            withinRange()
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

    func setFloat(_ v: Int)      { num = Float(v) ; withinRange() }
    func setFloat(_ v: Double)   { num = Float(v) ; withinRange() }
    func setFloat(_ v: CGFloat)  { num = Float(v) ; withinRange() }
    func setFloat(_ v: Float)    { num = v        ; withinRange() }

    func setFloat01(_ v: Int)    { setRangeFrom01(Float(v)) }
    func setFloat01(_ v: Double) { setRangeFrom01(Float(v)) }
    func setFloat01(_ v: CGFloat){ setRangeFrom01(Float(v)) }
    func setFloat01(_ v: Float)  { setRangeFrom01(v) }

    func increment()            { num += 1 ; withinRange() }
    func decrement()            { num -= 1 ; withinRange() }
}
