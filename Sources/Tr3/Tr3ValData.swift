//  Tr3ValData.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

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
}
extension Tr3ValData {

    override func printVal() -> String {
        return scriptVal()
    }
    override func scriptVal(parens: Bool = true,
                   session: Bool = false,
                   expand: Bool = true) -> String {
        return "[data]"
    }

}
