//
//  Tr3ValQuote.swift
//  Par iOS
//
//  Created by warren on 4/4/19.
//

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
        return Tr3ValQuote(with: self)
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
    override func setVal(_ from: Tr3Val) {
        if let f = from as? Tr3ValQuote {
            quote = f.quote
        }
    }
    override func setVal(_ from: Any?) {
        if let v = from as? String {
            quote = v
        }
    }

}
