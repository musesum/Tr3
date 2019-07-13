//
//  Tr3Val.swift
//  Par
//
//  Created by warren on 3/8/19.
//

import Foundation
protocol Tr3ValProtocal {

    func printVal() -> String
    func scriptVal(prefix:String, parens:Bool) -> String
    func dumpVal(prefix:String, parens:Bool, session:Bool) -> String
    func copy() -> Tr3Val
}

public class Tr3Val: Comparable, Tr3ValProtocal {

    static var nextId = 0
    static func getNextId() -> Int { nextId += 1 ; return nextId }

    var id = Tr3Val.getNextId()
    var tr3: Tr3?  // tr3 that declared and contains this value
    var valFlags = Tr3ValFlags(rawValue:0) // which combination of the following?

    public static func == (lhs: Tr3Val, rhs: Tr3Val) -> Bool {
        return lhs.valFlags == rhs.valFlags
    }
    public static func < (lhs: Tr3Val, rhs: Tr3Val) -> Bool {
        return lhs.id < rhs.id
    }

    init() {
    }
    init(with tr3Val: Tr3Val) {
        tr3 = tr3Val.tr3
        valFlags = tr3Val.valFlags
    }
    func parse(string:String) -> Bool {
        print("Tr3Val parsing:" + string)
        return true
    }
    // print current state "2" in `a:(0..9=2)`
    func printVal() -> String {
        return ""
    }
    // print reproducable script "a:(0..9=2)" in `a:(0..9=2)`
    func scriptVal(prefix:String = ":", parens:Bool = true) -> String {
        return " "
    }
    // print internal connections "a╌>w", "b╌>w", "c╌>w" in  `w<-(a ? 1 : b ? 2 : c ? 3)`
    func dumpVal(prefix:String = ":", parens:Bool = true, session:Bool = false) -> String {
        return " "
    }
    func copy() -> Tr3Val {
        return Tr3Val(with:self)
    }
    func setVal(_ fromVal: Tr3Val) {
    }
    func addFlag(_ flag_: Tr3ValFlags) {
        valFlags.insert(flag_)
    }
    func quoteVal()->String? {
        if let v = val as? Tr3ValQuote {
            return v.quoteVal
        }
        return nil
    }
    func rectVal() -> CGRect? {
        if let v = val as? Tr3ValTupple, v.size >= 4 {
            let x = v.nums[0].num
            let y = v.nums[1].num
            let w = v.nums[2].num
            let h = v.nums[3].num
            let rect = CGRect(x:x, y:y, with:w, height:h)
            return rect
        }
        return nil
    }
}


