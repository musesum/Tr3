//  Tr3ValEmbed.swift
//
//  Created by warren on 4/25/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par // Visitor

public class Tr3ValEmbed: Tr3Val {

    var embed = ""

    init(_ tr3: Tr3, str: String?) {
        super.init(tr3, "embed")
        embed = str ?? "??"
    }
    public static func == (lhs: Tr3ValEmbed, rhs: Tr3ValEmbed) -> Bool {
        return lhs.embed == rhs.embed
    }

    public override func getVal() -> Any {
        return embed
    }

    public override func setVal(_ any: Any?,
                                _ visitor: Visitor,
                                _ options: Tr3SetOptions? = nil) -> Bool {
        
        if let v = any as? Tr3ValEmbed {
            embed = v.embed
            return true
        }
        return false
    }

    public override func printVal() -> String {
        return embed
    }
    
    public override func scriptVal(_ scriptFlags: Tr3ScriptFlags = [.parens]) -> String {
        return " {{\n" + embed +  "}}\n"
    }

}
