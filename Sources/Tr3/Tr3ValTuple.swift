//
//  Tr3ValTuple.swift
//  Par iOS
//
//  Created by warren on 4/4/19.
//

import QuartzCore
import Par


public class Tr3ValTuple: Tr3Val {

    var names = [String]()
    var nums = [Tr3ValScalar]() // current values
    var dflt: Tr3Val? = nil  // default value applied to each element
    var parseFlag = Tr3ValFlags.init(rawValue: 0)

    override init () {
        super.init()
    }
    
    override init(with tr3Val: Tr3Val) {

        super.init(with: tr3Val)

        if let v = tr3Val as? Tr3ValTuple {

            valFlags = v.valFlags
            names.append(contentsOf: v.names)
            nums.append(contentsOf: v.nums)
            dflt = v.dflt
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
        nums = [x,y]
    }
    override func copy() -> Tr3ValTuple {
        return Tr3ValTuple(with: self)
    }

    public static func < (lhs: Tr3ValTuple, rhs: Tr3ValTuple) -> Bool {

        if rhs.nums.count == 0 || rhs.nums.count != lhs.nums.count {
            return false
        }
        var lsum = Float(0)
        var rsum = Float(0)

        for val in lhs.nums { lsum += val.num * val.num }
        for val in rhs.nums { rsum += val.num * val.num }
        return lsum < rsum
    }

    override func printVal() -> String {
        var script = "("
        for num in nums {
            script += script.parenSpace() + "\(num)"
        }
        return script.with(trailing:")") 
    }

    override func scriptVal(prefix:String = ":", parens:Bool) -> String  {

        var script = prefix

        if valFlags.contains(.tupNameNums) {
            script += "("
            let maxi = max(names.count,nums.count)
            for i in 0 ..< maxi {
                if i < names.count { script += script.parenSpace() + names[i] }
                if i < nums.count  { script += nums[i].scriptVal(parens: false) }
            }
            script = script.with(trailing:")")
        }
        else {
            if names.count > 0 {
                script += "("
                for name in names {
                    script += script.parenSpace() + name
                }
                script += nums.count > 0 ? "):" : ")"
            }
            if nums.count > 0 {
                script += "("
                for num in nums {
                    script += script.parenSpace() + num.scriptVal(prefix:"", parens: false)
                }
                script = script.with(trailing:")")
            }
        }
        script += dflt?.scriptVal() ?? ""
        script += script.parenSpace() // always have single trailing space
        return script
    }

    override func dumpVal(prefix:String = ":", parens:Bool, session:Bool = false) -> String  {
        if session {
            var script = prefix
            if nums.count > 0 {
                script += "("
                for num in nums {
                    script += script.parenSpace() + String(format:"%g",num.num)
                }
                script = script.with(trailing:")")
            }
            return script
        }
        else {
            return scriptVal(prefix: prefix, parens: parens)
        }
    }
//
//    func getVal() -> Tr3Val? {
//        if dflt != nil { return dflt }
//        return nums.last ?? nil
//    }

    func addPath(_ p:ParAny) {

        if let value = p.next.first?.value {
            names.append(value)
        }
    }
    func addNames(_ names_:[String]) {
        valFlags.insert(.tupNames)
        for name in names_ {
            names.append(name)
        }
    }
    func addNums(_ nums_:[String]) {
        valFlags.insert(.tupNums)
        for num in nums_ {
            nums.append(Tr3ValScalar(with:num))
        }
    }
    func addNameNums(_ nameNums_:[String]) {
        valFlags.insert(.tupNameNums)
        var isName = true
        for item in nameNums_ {
            if isName { names.append(item) }
            else      { nums.append(Tr3ValScalar(with:item)) }
            isName = !isName
        }
    }
    public override func setVal(_ any: Any?) {

        /// top off nums with proper number of scalars
        func insureNums(count insureCount:Int) {
            if nums.count <= insureCount { return }
            let newScalar = dflt as? Tr3ValScalar ?? Tr3ValScalar(with:0)
            for _ in nums.count ..< insureCount {
                nums.append(newScalar)
            }
        }
        func setFloat(_ v:Float) {
            insureNums(count: 1)
            nums[0].num = v
        }
        func setPoint(_ v:CGPoint) {

            insureNums(count: 2)
            nums[0].num = Float(v.x)
            nums[1].num = Float(v.y)
        }
        func setTuple(_ v:Tr3ValTuple) {

            if nums.count == v.nums.count {
                nums = v.nums
                names = v.names
            }
            else {
                setNamed(v)
            }
        }
        /// this is O(n^2) which can slow for large tuples
        ///
        ///     // usually used for
        ///     a(x:0) <- c(x:0 y:0)
        ///     b(y:0) <- c(x:0 y:0)
        ///
        func setNamed(_ v:Tr3ValTuple) {
            for j in 0 ..< v.names.count {
                for i in 0 ..< names.count {
                    if names[i] == v.names[j] {
                        nums[i] = v.nums[j]
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
