//  Tr3ValTuple.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

import QuartzCore
import Par


public class Tr3ValTuple: Tr3Val {

    var names = [String]()
    var scalars = [Tr3ValScalar]() // current values

    override init () {
        super.init()
    }
    
    override init(with tr3Val: Tr3Val) {

        super.init(with: tr3Val)

        if let v = tr3Val as? Tr3ValTuple {

            valFlags = v.valFlags
            names.append(contentsOf: v.names)
            scalars.append(contentsOf: v.scalars)
        }
        else {
            valFlags = .scalar // use default values
        }
    }
    convenience init(with p: CGPoint) {
        self.init()
        names = ["x","y"]
        let x = Tr3ValScalar(with: Float(p.x))
        let y = Tr3ValScalar(with: Float(p.y))
        scalars = [x,y]
    }
    override func copy() -> Tr3ValTuple {
        let newTr3ValTuple = Tr3ValTuple(with: self)
        return newTr3ValTuple
    }

    public static func < (lhs: Tr3ValTuple, rhs: Tr3ValTuple) -> Bool {

        if rhs.scalars.count == 0 || rhs.scalars.count != lhs.scalars.count {
            return false
        }
        var lsum = Float(0)
        var rsum = Float(0)

        for val in lhs.scalars { lsum += val.num * val.num }
        for val in rhs.scalars { rsum += val.num * val.num }
        return lsum < rsum
    }

    override func printVal() -> String {
        var script = "("
        for num in scalars {
            script += script.parenSpace() + "\(num)"
        }
        return script.with(trailing: ")")
    }

    override func scriptVal(parens: Bool) -> String  {
        var script = "("
        let count = max(names.count, scalars.count)
        if count > 0 {
            var delim = ""
            for i in 0..<count {
                script += delim
                if valFlags.contains(.tupNames) {
                    script += script.parenSpace() + names[i]
                }
                if valFlags.contains(.tupScalars) {
                    script += script.parenSpace() + scalars[i].scriptVal(parens: false)
                }
                delim = ","
            }
            script = script.with(trailing:")")
        }
        script += script.parenSpace() // always have single trailing space
        return script
    }

    override func dumpVal(parens: Bool, session: Bool = false) -> String  {
        if session {
            var script = "("
            var delim = ""
            if scalars.count > 0 {
                for num in scalars {
                    script += delim ; delim = ", "
                    script += script.parenSpace() + String(format:"%g",num.num)
                }
                script = script.with(trailing:")")
            }
            return script
        }
        else {
            return scriptVal(parens: parens)
        }
    }

    func addPath(_ p: ParItem) {

        if let value = p.nextPars.first?.value {
            names.append(value)
        }
    }
    func addName(_ name_: String?) {
        if let name = name_ {
            valFlags.insert(.tupNames)
            names.append(name)
        }
    }
    func addScalar(_ scalar_: Tr3ValScalar?) {
        if let scalar = scalar_ {
            valFlags.insert(.tupScalars)
            scalars.append(scalar)
        }
    }
    func addNames(_ names_: [String]) {
        valFlags.insert(.tupNames)
        for name in names_ {
            names.append(name)
        }
    }
    func addScalars(_ scalars_: [String]) {
        valFlags.insert(.tupScalars)
        for scalar in scalars_ {
            scalars.append(Tr3ValScalar(with: scalar))
        }
    }
    
    /// top off scalars with proper number of scalars
    func insureScalars(count insureCount: Int) {
        if scalars.count < insureCount {
            let dflt = Tr3ValScalar(with: Float(0))
            valFlags.insert(.tupScalars)
            for _ in scalars.count ..< insureCount {
                let num = dflt.copy() as! Tr3ValScalar
                scalars.append(num)
            }
        }
    }
    func setDefaults() {
        if valFlags.contains(.tupScalars) {
            insureScalars(count: names.count)
        }
    }

    public override func setVal(_ any: Any?,_ options: Any? = nil) {
        
        // from contains normalized values 0...1
        // let zero1 = (options as? Tr3SetOptions ?? []).contains(.zero1)

        func setFloat(_ v: Float) {
            insureScalars(count: 1)
            scalars[0].num = v
        }
        func setPoint(_ v: CGPoint) {

            insureScalars(count: 2)
            scalars[0].num = Float(v.x)
            scalars[1].num = Float(v.y)
        }
        func setTuple(_ v: Tr3ValTuple) {

            if scalars.count == v.scalars.count {
                for i in 0..<v.scalars.count {
                    scalars[i].setFromScalar(v.scalars[i])
                }
                names = v.names
            }
            else {

                setNamed(v)
            }
        }
        /**
         this is O(n^2) which can slow for large tuples

             // usually used for
             a(x:0) <- c(x:0 y:0)
             b(y:0) <- c(x:0 y:0)
        */
        func setNamed(_ v: Tr3ValTuple) {

            // if no names to map, then make insure that there are enough numbers
            if names.isEmpty || v.names.isEmpty {
                insureScalars(count: max(v.names.count, v.scalars.count))
            }
            // this is Ot(n^2), but is OK when n is small
            // such as `a:(x y) <- b:(x y)`
            for j in 0 ..< v.names.count {
                for i in 0 ..< names.count {
                    if names[i] == v.names[j] {
                        insureScalars(count: i+1)
                        scalars[i].setFromScalar(v.scalars[j])
                    }
                }
            }
        }

        // begin -------------------------

        if let any = any {
            switch any {
            case let v as Float:        setFloat(v)
            case let v as CGFloat:      setFloat(Float(v))
            case let v as Double:       setFloat(Float(v))
            case let v as CGPoint:      setPoint(v)
            case let v as Tr3ValTuple:  setTuple(v)
            default: print("*** mismatched setVal(\(any))")
            }
        }
    }
}
