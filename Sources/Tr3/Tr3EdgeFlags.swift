// Tr3EdgeFlags.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

public struct Tr3EdgeFlags: OptionSet {

    public let rawValue: Int

    public static let input   = Tr3EdgeFlags(rawValue: 1 << 0) ///  1 `<` in ` a << b            a <> b`
    public static let output  = Tr3EdgeFlags(rawValue: 1 << 1) ///  2 `>` in  `a >> b            a <> b`
    public static let solo    = Tr3EdgeFlags(rawValue: 1 << 2) ///  4 `=` in  `a <= b   a => b   a <=> b`
    public static let exclude = Tr3EdgeFlags(rawValue: 1 << 3) ///  8 `!` in  `a <! b   a !> b   a <!> b`
    public static let ternIf  = Tr3EdgeFlags(rawValue: 1 << 5) /// 32 ternary `a⟐→z` in `z(a ? b : c)`
    public static let ternGo  = Tr3EdgeFlags(rawValue: 1 << 6) /// 64 ternary `b◇→z`,`c◇→` in `z(a ? b : c)`
    public static let copyat  = Tr3EdgeFlags(rawValue: 1 << 7) /// 64 a @ b
    public init(rawValue: Int = 0) { self.rawValue = rawValue }

    public init(with str: String) {
        self.init()
        for char in str {
            switch char {
            case "<","←": self.insert(.input)   // callback
            case ">","→": self.insert(.output)  // call out
            case "⟡"    : self.insert(.solo)    // overwrite
            case "!"    : self.insert(.exclude) // remove edge(s) //TODO: test
            case "?"    : self.insert(.ternIf)  // edge to ternary condition
            case "@"    : self.insert(.copyat)  // edge to ternary condition
            default     : continue
            }
        }
    }
    public init(flipIO: Tr3EdgeFlags) {
        self.init(rawValue: flipIO.rawValue)

        let hasInput  = self.contains(.input)
        let hasOutput = self.contains(.output)
        // flip inputs and outputs, if have both, then remains the same
        if hasInput  { insert(.output) } else { remove(.output) }
        if hasOutput { insert(.input)  } else { remove(.input)  }
    }

    public func scriptExpicitFlags() -> String {

        switch self {
            case [.input,.output]: return "<>"
            case [.input]: return "<<"
            case [.output]: return ">>"
            default: print( "⚠️ unexpected scriptEdgeFlags")
        }
        return ""
    }
    public func scriptImplicitFlags(_ active: Bool) -> String {

        var script = self.contains(.input) ? "←" : ""

        if active == false              { script += "◇" }
        else if self.contains(.solo)    { script += "⟡" }
        else if self.contains(.ternIf)  { script += "⟐" }
        else if self.contains(.ternGo)  { script += "⟐" }
        else if self.contains(.copyat)  { script += "@" }
        else if active == false         { script += "◇" }

        script += self.contains(.output) ? "→" : ""

        return script
    }
    var isImplicit: Bool {
        self.intersection([.solo,
                           .ternIf,
                           .ternGo,
                           .copyat]) != []
    }

    public func script(active: Bool = true) -> String {
        if isImplicit {
            return scriptImplicitFlags(active)
        } else {
            return scriptExpicitFlags()
        }
    }


}
