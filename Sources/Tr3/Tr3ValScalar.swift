//  Tr3ValScalar.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import QuartzCore
import Foundation
import Par // visitor
import MuTime // NextFrame

public class Tr3ValScalar: Tr3Val {


    // default scalar value is (0…1 = 1)
    public var now = Double(0) // current value; 2 in 0…3=1:2
    var next = Double(0) // target value
    var anim = TimeInterval.zero
    var steps = TimeInterval.zero

    var min  = Double(0) // minimum value; 0 in 0…3
    var max  = Double(1) // maximum value; 3 in 0…3
    var dflt = Double(0) // default value; 1 in 0…3=1

    override init(_ tr3: Tr3, _ name: String) {
        super.init(tr3, name)
        self.name = name
    }

    init(_ tr3: Tr3, name: String, num: Double) {
        super.init(tr3, name)
        valFlags = .now
        self.min = fmin(num, 0.0)
        self.max = fmax(num, 1.0)
        self.now = num
    }

    init (with scalar: Tr3ValScalar) {
        super.init(scalar.tr3, scalar.name)
        valFlags = scalar.valFlags // use default values
        min  = scalar.min
        max  = scalar.max
        dflt = scalar.dflt
        now  = scalar.now
    }

    public func normalized() -> Double {
        if valFlags.contains([.min,.max]) {
            let range = max - min
            let ret = (now - min) / range
            return ret
        } else {
            print("🚫 \(tr3.name): cannot normalize \(now)")
            return now
        }
    }
    public func range() -> ClosedRange<Double> {
        return min...max
    }

    func setNow() { // was setDefault //??

        if !valFlags.now {
             setDefault()
        }
    }
    func setAnim(_ val: Double) {
        valFlags.insert(.anim)
        anim = val
    }

    func setDefault() { // was setDefault

        if      valFlags.dflt           { now = dflt }
        else if valFlags.min, now < min { now = min  }
        else if valFlags.max, now > max { now = max  }
        else if valFlags.modu           { now = 0    }
    }
    static func |= (lhs: Tr3ValScalar, rhs: Tr3ValScalar) {
        
        let mergeFlags = lhs.valFlags.rawValue |  rhs.valFlags.rawValue
        lhs.valFlags = Tr3ValFlags(rawValue: mergeFlags)
        if rhs.valFlags.min { lhs.min = rhs.min }
        if rhs.valFlags.max { lhs.max = rhs.max }
        if rhs.valFlags.now { lhs.now = rhs.now }
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

    public func inRange(from: Double) -> Bool {

        if valFlags.modu, from > max { return false }
        if valFlags.min , from < min { return false }
        if valFlags.max , from > max { return false }
        return true
    }

    public override func printVal() -> String {
        return String(now)
    }

    public override func scriptVal(_ scriptFlags: Tr3ScriptFlags) -> String {

        if scriptFlags.delta {
            if !hasDelta() {
                return ""
            }
            print("*** \(tr3.name) [\(scriptFlags.description)].[\(valFlags.description)] : \(now)") //??
        }

        var script = scriptFlags.parens ? "(" : ""
        if valFlags.rawValue == 0   { return "" }

        if scriptFlags.def {
            if valFlags.min  { script += min.digits(0...6) }
            if valFlags.thru { script += "…" /* option+`;` */}
            if valFlags.modu { script += "%" }
            if valFlags.max  { script += max.digits(0...6) }
            if valFlags.dflt { script += "=" + dflt.digits(0...6) }
            if valFlags.lit  { script += now.digits(0...6) }
            if scriptFlags.now {
                if valFlags.lit, now == dflt {
                    /// skip as `dflt` will set `now` anyway
                 } else {
                    script += ":" + now.digits(0...6)
                }
            }
        } else if scriptFlags.now {
            if valFlags.lit, now == dflt {
                script += now.digits(0...6)
            } else {
                script += ":" + now.digits(0...6)
            }
        } else if valFlags.lit {
            script += now.digits(0...6)
        }
        script += scriptFlags.parens ? ")" : ""
        return script
    }
    
    override public func hasDelta() -> Bool {
        if valFlags.now {
            if valFlags.dflt {
                if now != dflt { return true }
            } else {
                return true
            }
        }
        return false
    }

    // MARK: - set

    public override func setVal(_ val: Any?,
                                _ visitor: Visitor,
                                _ options: Tr3SetOptions? = nil) -> Bool {

        //??? if visitor.wasHere(id) { return false }

        if let val {
            switch val {
                case let v as Tr3ValScalar : setFrom(v)
                case let v as Double       : setNumWithFlag(v)
                case let v as Float        : setNumWithFlag(Double(v))
                case let v as CGFloat      : setNumWithFlag(Double(v))
                case let v as Int          : setNumWithFlag(Double(v))
                default: print("🚫 setVal unknown type for: from")
            }
            animateNowToNext()
        }

        return true

        func animateNowToNext() {
            if valFlags.anim {
                print("􁒖")
                steps = NextFrame.shared.fps * anim
                NextFrame.shared.addFrameDelegate(self.id, self)
            } else {
                now = next
            }
        }

        func setFrom(_ v: Tr3ValScalar) {

            if   valFlags.thru,
                 v.valFlags.thru {

                let toMax   = max
                let frMax   = v.max
                let toRange = toMax -   min
                let frRange = frMax - v.min
                next = (v.now - v.min) * (toRange / frRange) + min
                valFlags.insert(.now)
            }
            else if valFlags.modu {

                min = 0
                max = Double.maximum(1, max)
                next = fmod(v.now, max)
            }
            else {
                setNumWithFlag(v.now)
            }
        }

        func setNumWithFlag(_ n: Double) {
            next = n
            valFlags.insert(.now)
            setInRange()
        }
        
        func setInRange() {

            if valFlags.modu { next = fmod(next, max) }
            if valFlags.min , next < min { next = min }
            if valFlags.max , next > max { next = max }
        }
    }

    public override func getVal() -> Any {
        return now
    }

    public override func copy() -> Tr3Val {
        let newTr3ValScalar = Tr3ValScalar(with: self)
        return newTr3ValScalar
    }
}

extension Tr3ValScalar: NextFrameDelegate {

    public func nextFrame() -> Bool {
        let delta = (next - now)
        if delta == 0 { steps = 0 ; return false }
        now += (steps <= 1 ? delta : delta / steps)
        steps = Swift.max(0.0, steps - 1)
        print("􀎶 \(tr3.name).\(name).\(id) \(now.digits(3...3)) ~> \(next.digits(3...3)) steps: \(steps.digits(0...1))")
        tr3.activate(Visitor(tr3.id, from: .animate))
        return steps > 0
    }

}
