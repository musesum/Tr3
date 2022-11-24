//  Tr3ValScalar.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import QuartzCore

public class Tr3ValScalar: Tr3Val {

    // default scalar value is (0…1 = 1)

    public var min  = Float(0) // minimum value; 0 in 0…3
    public var max  = Float(1) // maximum value; 3 in 0…3
    public var dflt = Float(0) // default value; 1 in 0…3=1
    public var now  = Float(0) // current value; 2 in 0…3=1:2

    override init(_ tr3: Tr3? = nil) {
        super.init(tr3)
    }

    init(_ tr3: Tr3? = nil, num: Float) {
        super.init(tr3)
        valFlags = .now
        self.min = fmin(num, 0.0)
        self.max = fmax(num, 1.0)
        self.now = num
    }

    init (with scalar: Tr3ValScalar) {
        super.init(scalar.tr3)
        valFlags = scalar.valFlags // use default values
        min  = scalar.min
        max  = scalar.max
        dflt = scalar.dflt
        now  = scalar.now
    }
    override func copy() -> Tr3Val {
        let newTr3ValScalar = Tr3ValScalar(with: self)
        return newTr3ValScalar
    }

    func parseNum(_ n: Float) {

        if valFlags.contains(.thru) {
            if valFlags.contains(.max) {
                now = n
            } else if valFlags.contains(.min) {
                valFlags.insert(.max)
                max = n
            } else {
                valFlags.insert(.min)
                min = n
            }
        } else if valFlags.contains(.modu) {
            if valFlags.contains(.max) {
                now = n
            } else {
                valFlags.insert(.max)
                max = n
            }
        } else {
            valFlags.insert(.lit)
            now = n
        }
    }
    func parseDflt(_ n: Float) {
        if !n.isNaN {
            valFlags.insert(.dflt)
            dflt = n
            now = n
        }
    }
    func parseNow(_ n: Float) {
        if !n.isNaN {
            valFlags.insert(.now) //??? 
            now = n
        }
    }
    func setNow() { // was setDefault
        if valFlags.contains(.now) {
            // do nothing
        } else if valFlags.contains(.dflt) {
            now = dflt
        } else if valFlags.contains(.min), now < min {
            now = min
        } else if valFlags.contains(.max), now > max {
            now = max
        } else if valFlags.contains(.modu) {
            now = 0
        }
    }

    static func |= (lhs: Tr3ValScalar, rhs: Tr3ValScalar) {
        
        let mergeFlags = lhs.valFlags.rawValue |  rhs.valFlags.rawValue
        lhs.valFlags = Tr3ValFlags(rawValue: mergeFlags)
        if rhs.valFlags.contains(.min) { lhs.min = rhs.min }
        if rhs.valFlags.contains(.max) { lhs.max = rhs.max }
        if rhs.valFlags.contains(.now) { lhs.now = rhs.now }
    }

    public static func == (lhs: Tr3ValScalar,
                           rhs: Tr3ValScalar) -> Bool { return lhs.now == rhs.now }
    public static func >= (lhs: Tr3ValScalar,
                           rhs: Tr3ValScalar) -> Bool { return lhs.now >= rhs.now }
    public static func >  (lhs: Tr3ValScalar,
                           rhs: Tr3ValScalar) -> Bool { return lhs.now >  rhs.now }
    public static func <= (lhs: Tr3ValScalar,
                           rhs: Tr3ValScalar) -> Bool { return lhs.now <= rhs.now }
    public static func <  (lhs: Tr3ValScalar,
                           rhs: Tr3ValScalar) -> Bool { return lhs.now <  rhs.now }
    public static func != (lhs: Tr3ValScalar,
                           rhs: Tr3ValScalar) -> Bool { return lhs.now != rhs.now }

    public func inRange(from: Float) -> Bool {

        if valFlags.contains(.modu), from > max { return false }
        if valFlags.contains(.min),  from < min { return false }
        if valFlags.contains(.max),  from > max { return false }
        return true
    }


    public override func setVal(_ val: Any?,
                                _ options: Tr3SetOptions? = nil) -> Bool {

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
        return true
        
        func setFromScalar(_ v: Tr3ValScalar) {

            if   valFlags.contains(.thru),
                 v.valFlags.contains(.thru) {

                let toMax   = max
                let frMax   = v.max
                let toRange = toMax -   min
                let frRange = frMax - v.min
                now = (v.now - v.min) * (toRange / frRange) + min
                valFlags.insert(.now)
            }
            else if valFlags.contains(.modu) {

                min = 0
                max = fmaxf(1, max)
                now = fmodf(v.now, max)
            }
            else {
                setNumWithFlag(v.now)
            }
        }
        func setFromFloat(_ v: Int)      { setNumWithFlag(Float(v)) }
        func setFromFloat(_ v: Double)   { setNumWithFlag(Float(v)) }
        func setFromFloat(_ v: CGFloat)  { setNumWithFlag(Float(v)) }
        func setFromFloat(_ v: Float)    { setNumWithFlag(v       ) }
        
        func setNumWithFlag(_ n: Float) {
            now = n
            valFlags.insert(.now) //???
            setInRange()
        }
        func setInRange() {

            if valFlags.contains(.modu) { now = fmodf(now, max) }
            if valFlags.contains(.min), now < min { now = min }
            if valFlags.contains(.max), now > max { now = max }
        }
    }
    public override func getVal() -> Any {
        return now
    }

    public override func printVal() -> String {
        return String(now)
    }

    public override func scriptVal(_ scriptFlags: Tr3ScriptFlags) -> String {

        if scriptFlags.contains(.delta) {
            if !hasDelta() {
                return ""
            }
            print("*** \(tr3?.name ?? "") [\(scriptFlags.description)].[\(valFlags.description)] : \(now)") //???
        }

        var script = scriptFlags.contains(.parens) ? "(" : ""
        if valFlags.rawValue == 0   { return "" }

        if scriptFlags.contains(.def) {
            if valFlags.contains(.min)  { script += String(format: "%g", min) }
            if valFlags.contains(.thru) { script += "…" /* option+`;` */}
            if valFlags.contains(.modu) { script += "%" }
            if valFlags.contains(.max)  { script += String(format: "%g", max) }
            if valFlags.contains(.dflt) { script += String(format: "=%g", dflt) }
            if valFlags.contains(.lit) { script += String(format: "%g", now) }
            if scriptFlags.contains(.now) {
                if valFlags.hasDef() {
                    /// `:2` in `0…3=1:2`
                    script += String(format: ":%g", now)
                } else if valFlags.contains(.lit) {
                    /// `2` in `a(2)`
                    /// skip
                } else {
                    script += String(format: "%g", now)
                }
            }
        } else if scriptFlags.contains(.now), valFlags.contains(.now) {
            script += String(format: "%g", now)
        } else if valFlags.contains(.lit) {
            script += String(format: "%g", now)
        }
        script += scriptFlags.contains(.parens) ? ")" : ""
        return script
    }
    
    override public func hasDelta() -> Bool {
        if valFlags.contains(.now) {
            if valFlags.contains(.dflt) {
                if now != dflt { return true }
            } else {
                return true
            }
        }
        return false
    }
}
