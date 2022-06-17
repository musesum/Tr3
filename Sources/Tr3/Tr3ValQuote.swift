//  Tr3ValQuote.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation


public class Tr3ValQuote: Tr3Val {

    var quote = ""

    init(with str: String?) {
        super.init()
        quote = str ?? "??"
    }
    init(with val: Tr3ValQuote) {
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


    public override func setVal(_ any: Any?, _ options: Tr3SetOptions? = nil) {
        if let v = any as? String {
            quote = v
        }
        else if let v = any as? Tr3ValQuote {
             quote = v.quote
        }
    }
    public override func getVal() -> Any {
        return quote
    }

}
extension Tr3ValQuote {

    override func printVal() -> String {
        return quote
    }

    override func scriptVal(parens: Bool = true,
                            session: Bool = false,
                            expand: Bool = false) -> String  {
        return "\"" + quote +  "\" "
    }
}
