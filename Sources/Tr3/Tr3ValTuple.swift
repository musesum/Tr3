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
                    script += script.parenSpace() + num.scriptVal(prefix:"", parens: false)
                }
                script = script.with(trailing:")")
            }
            return script
        }
        else {
            return scriptVal(prefix: prefix, parens: parens)
        }
    }

    func getVal() -> Tr3Val? {
        if dflt != nil { return dflt }
        return nums.last ?? nil
    }

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
    override func setVal(_ any: Any?) {

        if let any = any {
            switch any {
            case let v as CGPoint:
                if nums.count >= 2 {
                    nums[0].num = Float(v.x)
                    nums[1].num = Float(v.y)
                }
                else {
                    print("*** mismatched nums(\(v))")
                }
            case let v as Tr3ValTuple:
                nums = v.nums
                names = v.names
            default: print("*** mismatched setVal(\(any))")
            }
        }
    }
}
