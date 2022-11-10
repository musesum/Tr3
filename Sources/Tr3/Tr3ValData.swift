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

    override init(_ tr3: Tr3?) {
        super.init(tr3)
    }
    init(with: Tr3ValData) {
        super.init(with.tr3)
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

    public override func printVal() -> String {
        return scriptVal()
    }
    public override func scriptVal(_ scriptFlags: Tr3ScriptFlags = [.parens,.expand]) -> String {
        return "[data]"
    }

}
