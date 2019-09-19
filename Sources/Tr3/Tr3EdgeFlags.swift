// Tr3EdgeFlags.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

import Foundation

public struct Tr3EdgeFlags: OptionSet {

    public let rawValue: Int

    public static let input   = Tr3EdgeFlags(rawValue: 1 << 0) // 1  < in  a<-b         a<->b
    public static let output  = Tr3EdgeFlags(rawValue: 1 << 1) // 2 > in  a->b          a<->b
    public static let solo    = Tr3EdgeFlags(rawValue: 1 << 2) // 4 + in  a<=b    a=>B   a<+>b

    public static let exclude = Tr3EdgeFlags(rawValue: 1 << 3) //  8 ! in  a<!b   a!>b   a<!>b
    public static let find    = Tr3EdgeFlags(rawValue: 1 << 4) // 16 ? in  a<:b   a:>b   a<:>b
    public static let ternary = Tr3EdgeFlags(rawValue: 1 << 5) // 32  a?>w, b?>w x<╌>w y<╌>w in  a b x y w<->(a ? x : b ? y)
 
    public init(rawValue:Int = 0) { self.rawValue = rawValue }

    public init(with:String) {
        self.init()
        for char in with {
            switch char {
            case "<": self.insert(.input)   // callback
            case ">": self.insert(.output)  // call out
            case "=": self.insert(.solo)    // overwrite
            case "!": self.insert(.exclude) // remove edge(s)
            case ":": self.insert(.find)    // find edge(s) but dont connect
            case "?": self.insert(.ternary) // edge to ternary condition
            default: continue
            }
        }
    }
    public init(flipIO:Tr3EdgeFlags) {
        self.init(rawValue: flipIO.rawValue)

        let hasInput  = self.contains(.input)
        let hasOutput = self.contains(.output)
        // flip inputs and outputs, if have both, then remains the same
        if hasInput  { insert(.output) } else { remove(.output) }
        if hasOutput { insert(.input)  } else { remove(.input)  }
    }
}
