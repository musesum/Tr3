//  Tr3ValQuote.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

import Foundation


public class Tr3ValQuote: Tr3Val {

    var quote = ""

    init(with str:String?) {
        super.init()
        quote = str ?? "??"
    }
    init(with val:Tr3ValQuote) {
        super.init()
        quote = val.quote
    }
    override func copy() -> Tr3Val {
        let newTr3ValQuote = Tr3ValQuote(with: self)
        return newTr3ValQuote
    }
    public static func == (lhs: Tr3ValQuote, rhs: Tr3ValQuote) -> Bool {
        return lhs.quote == rhs.quote
    }
    override func printVal() -> String {
        return quote
    }
    override func scriptVal(prefix:String = ":", parens:Bool = true) -> String  {
        return prefix +  "\"" + quote +  "\" "
    }
    override func dumpVal(prefix:String = ":", parens:Bool = true, session:Bool = false) -> String  {
        return scriptVal(prefix:prefix, parens:parens)
    }
    public override func setVal(_ any: Any?, _ options:Any? = nil) {
        if let v = any as? String {
            quote = v
        }
        else if let v = any as? Tr3ValQuote {
             quote = v.quote
        }
    }

}
