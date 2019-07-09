//
//  Tr3ValTuple.swift
//  Par iOS
//
//  Created by warren on 4/4/19.
//

import Foundation
import Par

/**
 Test vector length between two tuples of n dimension sum(vals[i] * vals[i])
 */
public class Tr3ValTuple: Tr3Val {

    var size = 0       // number of values
    var names = [String]()
    var nums = [Tr3ValScalar]() // current values
    var dflt: Tr3Val? = nil  // default value applied to each element
    var parseFlag = Tr3ValFlags.init(rawValue: 0)

    override init () {
        super.init()
    }
    
    override init (with tr3Val: Tr3Val) {

        super.init(with: tr3Val)

        if let v = tr3Val as? Tr3ValTuple {

            valFlags = v.valFlags
            size  = v.size
            names.append(contentsOf: v.names)
            nums.append(contentsOf: v.nums)
            dflt = v.dflt
        }
        else {

            valFlags = .scalar // use default values
        }
    }
    override func copy() -> Tr3ValTuple {
        return Tr3ValTuple(with: self)
    }
    public static func < (lhs: Tr3ValTuple, rhs: Tr3ValTuple) -> Bool {

        if rhs.size == 0 || rhs.size != lhs.size {
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

    override func setVal(_ fromVal: Tr3Val) {
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
}
