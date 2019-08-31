//
//  Tr3ValData.swift
//  Par iOS
//
//  Created by warren on 4/4/19.
//

import Foundation


public class Tr3ValData: Tr3Val {

    var data: UnsafeMutablePointer<UInt8>? = nil
    var size = 0
    var filename = ""

    override init() {
        super.init()
    }
    init(with: Tr3ValData) {
        super.init()
        size = with.size
        filename = with.filename
        data = with.data //TODO: allocate new memory and copy}
    }
    override func copy() -> Tr3Val {
        let newTr3ValData = Tr3ValData(with: self)
        return newTr3ValData
    }
    public static func == (lhs: Tr3ValData, rhs: Tr3ValData) -> Bool {

        if rhs.size == 0 || rhs.size != lhs.size {
            return false
        }
        let lbuf = lhs.data
        let rbuf = rhs.data

        for i in 0 ..< lhs.size {
            if lbuf![i] != rbuf![i] {
                return false
            }
        }
        return true
    }
    override func printVal() -> String {
        return dumpVal()
    }
    override func scriptVal(prefix:String = ":", parens:Bool = true) -> String {
        return prefix + "[data]"
    }
    override func dumpVal(prefix:String = ":", parens:Bool = true, session:Bool = false) -> String {
        return prefix + "[data]"
    }

}
