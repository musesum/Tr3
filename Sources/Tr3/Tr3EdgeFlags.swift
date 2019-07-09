//
//  Tr3EdgeFlags.swift
//  Par iOS
//
//  Created by warren on 3/10/19.
//

import Foundation

public struct Tr3EdgeFlags: OptionSet {

    public let rawValue: Int

    public static let input   = Tr3EdgeFlags(rawValue: 1 << 0) // 1  < in  a<-b         a<->b
    public static let output  = Tr3EdgeFlags(rawValue: 1 << 1) // 2 > in  a->b          a<->b
    public static let nada    = Tr3EdgeFlags(rawValue: 1 << 2) // 4 ! in  a<!b   a!>b   a<!>b
    public static let find    = Tr3EdgeFlags(rawValue: 1 << 3) // 8 ? in  a<:b   a:>b   a<:>b
    public static let ternary = Tr3EdgeFlags(rawValue: 1 << 4) // 16  a?>w, b?>w x<╌>w y<╌>w in  a b x y w<->(a ? x : b ? y)
    //public static let clone   = Tr3EdgeFlags(rawValue: 1 << 5) // 32  b.d.f, b.e.f in `a {b c}:{d e}:{f g}:{i j} a.b~f <- (f.i ? 1 | a~j ? 0)`

    public init(rawValue:Int = 0) { self.rawValue = rawValue }

    public init(with:String) {
        self.init()
        for char in with {
            switch char {
            case "<": self.insert(.input)
            case "!": self.insert(.nada)
            case ":": self.insert(.find)
            case "?": self.insert(.ternary)
            case ">": self.insert(.output)
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
