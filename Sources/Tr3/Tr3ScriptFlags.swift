//
//  File.swift
//  
//
//  Created by warren on 11/10/22.
//

import Foundation


public struct Tr3ScriptFlags: OptionSet {

    public let rawValue: Int

    public static let def     = Tr3ScriptFlags(rawValue: 1 << 0) ///  1 defined values `0…3=1` in  `a(x 0…3=1)`
    public static let now     = Tr3ScriptFlags(rawValue: 1 << 1) ///  2 current value `2` in `a(x 2)` or `a(x 0…3=1:2)`
    public static let edge    = Tr3ScriptFlags(rawValue: 1 << 2) ///  4 `>> (b c d)` in `a >> (b c d)`
    public static let compact = Tr3ScriptFlags(rawValue: 1 << 3) ///  8 `a.b` instead of `a { b }`
    public static let parens  = Tr3ScriptFlags(rawValue: 1 << 4) /// 16 `(1)` in `a(1)` but not `2` in `b(x 2)`
    public static let expand  = Tr3ScriptFlags(rawValue: 1 << 5) /// 32 expand edgeDef to full list edges
    public static let comment = Tr3ScriptFlags(rawValue: 1 << 6) /// 64 commas (`,`) and `// comment`
    public static let delta   = Tr3ScriptFlags(rawValue: 1 << 7) /// 128 only values where `.now != .dflt`
    public static let copyAt  = Tr3ScriptFlags(rawValue: 1 << 8) /// 256 `@ output` in `input @ output`

    public init(rawValue: Int = 0) { self.rawValue = rawValue }
}

extension Tr3ScriptFlags: CustomStringConvertible {

    static public var debugDescriptions: [(Self, String)] = [
        (.def     , "def"     ),
        (.now     , "now"     ),
        (.edge    , "edge"    ),
        (.compact , "compact" ),
        (.parens  , "parens"  ),
        (.expand  , "expand"  ),
        (.comment , "comment" ),
        (.delta   , "delta"   ),
        (.copyAt  , "copyAt"  ),
    ]

    public var description: String {
        let result: [String] = Self.debugDescriptions.filter { contains($0.0) }.map { $0.1 }
        let joined = result.joined(separator: ", ")
        return "\(joined)"
    }
}

