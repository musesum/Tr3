//  Tr3ValFlags.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

public struct Tr3ValFlags: OptionSet {

    public static let thru    = Tr3ValFlags(rawValue: 1 <<  1) // 0…1 range including 1
    public static let modu    = Tr3ValFlags(rawValue: 1 <<  2) // %2 modulo
    public static let min     = Tr3ValFlags(rawValue: 1 <<  3) // 0 in 0…1, min of range
    public static let max     = Tr3ValFlags(rawValue: 1 <<  4) // 1 in 0…1, max of range
    public static let num     = Tr3ValFlags(rawValue: 1 <<  5) // current value
    public static let dflt    = Tr3ValFlags(rawValue: 1 <<  6) // = n default value
    public static let quote   = Tr3ValFlags(rawValue: 1 <<  7) // General type Tr3ValQuote
    public static let embed   = Tr3ValFlags(rawValue: 1 <<  8) // embed script in double {{ … }}
    public static let exprs   = Tr3ValFlags(rawValue: 1 <<  9) // for an array of scalars
    public static let names   = Tr3ValFlags(rawValue: 1 << 10) // (x, y)
    public static let ternary = Tr3ValFlags(rawValue: 1 << 11) // a ? b : c

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
}
extension Tr3ValFlags: CustomStringConvertible {

    static public var debugDescriptions: [(Self, String)] = [
        (.thru    , "thru"    ),
        (.modu    , "modu"    ),
        (.min     , "min"     ),
        (.max     , "max"     ),
        (.num     , "num"     ),
        (.dflt    , "dflt"    ),
        (.quote   , "quote"   ),
        (.embed   , "embed"   ),
        (.exprs   , "exprs"   ),
        (.ternary , "ternary" ),
    ]

    public var description: String {
        let result: [String] = Self.debugDescriptions.filter { contains($0.0) }.map { $0.1 }
        let joined = result.joined(separator: ", ")
        return "\(joined)"
    }
}
