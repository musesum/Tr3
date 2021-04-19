//  Tr3ValFlags.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

public struct Tr3ValFlags: OptionSet {

    public let rawValue: Int

    public static let scalar  = Tr3ValFlags(rawValue: 1 <<  0) // 1 General type Tr3ValScalar
    public static let thru    = Tr3ValFlags(rawValue: 1 <<  2) // 0...1 in a:(0...1),range including 1
    public static let modu    = Tr3ValFlags(rawValue: 1 <<  3) // 2 in a:(%2), modulo

    // explicitly declared values
    public static let min     = Tr3ValFlags(rawValue: 1 <<  6) // 0 in 0...1, min of range
    public static let max     = Tr3ValFlags(rawValue: 1 <<  7) // 1 in 0...1, max of range
    public static let num     = Tr3ValFlags(rawValue: 1 <<  8) // current value
    public static let dflt    = Tr3ValFlags(rawValue: 1 <<  9) // =n default value

    public static let quote   = Tr3ValFlags(rawValue: 1 << 11) // General type Tr3ValQuote
    public static let embed   = Tr3ValFlags(rawValue: 1 << 12) // embed script between double {{ ... }}

    public static let data    = Tr3ValFlags(rawValue: 1 << 13) // General type Tr3ValData for palettes, universe, etc

    public static let timing  = Tr3ValFlags(rawValue: 1 << 14) //
    public static let script  = Tr3ValFlags(rawValue: 1 << 15) // for embedded script between name(){...} -- for example shaders

    public static let exprs      = Tr3ValFlags(rawValue: 1 << 16) // for an array of scalars
    public static let exprNames   = Tr3ValFlags(rawValue: 1 << 17) // 0..n names
    public static let exprScalars = Tr3ValFlags(rawValue: 1 << 18) // 0..n scalars
    public static let ternary    = Tr3ValFlags(rawValue: 1 << 21) // ternary a ? b : c
    public static let path       = Tr3ValFlags(rawValue: 1 << 22) // path to tr3 in a ? b : c
    public init(rawValue: Int) { self.rawValue = rawValue }

}
extension Tr3ValFlags: CustomStringConvertible {

    static public var debugDescriptions: [(Self, String)] = [
        (.scalar     , "scalar"     ),
        (.thru       , "thru"       ),
        (.modu       , "modu"       ),
        (.min        , "min"        ),
        (.max        , "max"        ),
        (.num        , "num"        ),
        (.dflt       , "dflt"       ),
        (.quote      , "quote"      ),
        (.embed      , "embed"      ),
        (.data       , "data"       ),
        (.timing     , "timing"     ),
        (.script     , "script"     ),
        (.exprs      , "exprs"      ),
        (.exprNames  , "exprNames"  ),
        (.exprScalars, "exprScalars"),
        (.ternary    , "ternary"    ),
        (.path       , "path"       )
    ]

    public var description: String {
        let result: [String] = Self.debugDescriptions.filter { contains($0.0) }.map { $0.1 }
        let printable = result.joined(separator: ", ")

        return "\(printable)"
    }
}
