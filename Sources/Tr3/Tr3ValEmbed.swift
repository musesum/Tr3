//
//  Tr3ValEmbed.swift
//  Par iOS
//
//  Created by warren on 4/25/19.
//

import Foundation


public class Tr3ValEmbed: Tr3Val {

    var embed = ""

    init(with str:String?) {
        super.init()
        embed = str ?? "??"
    }
    public static func == (lhs: Tr3ValEmbed, rhs: Tr3ValEmbed) -> Bool {
        return lhs.embed == rhs.embed
    }
    override func printVal() -> String {
        return embed
    }
    override func scriptVal(prefix:String, parens:Bool = true) -> String  {
        return " {{\n" + embed +  "}}\n"
    }
    override func dumpVal(prefix:String = " ", parens:Bool = true, session:Bool = false) -> String  {
        return scriptVal(prefix:prefix, parens:parens)
    }
    override func setVal(_ from: Tr3Val) {
    }

}
