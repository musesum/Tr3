// Tr3EdgeFlags.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

public struct Tr3EdgeFlags: OptionSet {

    public let rawValue: Int

    public static let input   = Tr3EdgeFlags(rawValue: 1 << 0) //  1 < in  a << b            a <> b
    public static let output  = Tr3EdgeFlags(rawValue: 1 << 1) //  2 > in  a >> b            a <> b
    public static let solo    = Tr3EdgeFlags(rawValue: 1 << 2) //  4 = in  a <= b   a => b   a <=> b
    public static let exclude = Tr3EdgeFlags(rawValue: 1 << 3) //  8 ! in  a <! b   a !> b   a <!> b
    public static let ternary = Tr3EdgeFlags(rawValue: 1 << 5) // 32 a?>w, b ?> w x<╌>w  y<╌>w i n  a b x y w<->(a ? x : b ? y)
    public static let copyat  = Tr3EdgeFlags(rawValue: 1 << 6) // 64
    public init(rawValue: Int = 0) { self.rawValue = rawValue }

    public init(with str: String) {
        self.init()
        for char in str {
            switch char {
            case "<": self.insert(.input)   // callback
            case ">": self.insert(.output)  // call out
            case "=": self.insert(.solo)    // overwrite
            case "!": self.insert(.exclude) // remove edge(s) //TODO: test
            case "?": self.insert(.ternary) // edge to ternary condition
            case ":": self.insert(.copyat)  // edge to ternary condition
            default: continue
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
}
