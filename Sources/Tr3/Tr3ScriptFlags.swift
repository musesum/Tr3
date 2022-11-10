//
//  File.swift
//  
//
//  Created by warren on 11/10/22.
//

import Foundation


public struct Tr3ScriptFlags: OptionSet {

    public let rawValue: Int

    public static let def     = Tr3ScriptFlags(rawValue: 1 << 0) //  1  a(x 0…3=1)
    public static let now     = Tr3ScriptFlags(rawValue: 1 << 1) //  2  a(x 2)
    public static let edge    = Tr3ScriptFlags(rawValue: 1 << 2) //  4  a >> p˚
    public static let compact = Tr3ScriptFlags(rawValue: 1 << 3) //  8
    public static let parens  = Tr3ScriptFlags(rawValue: 1 << 4) // 16
    public static let expand  = Tr3ScriptFlags(rawValue: 1 << 5) // 32


    public init(rawValue: Int = 0) { self.rawValue = rawValue }

}
extension Tr3ScriptFlags: CustomStringConvertible {

    static public var debugDescriptions: [(Self, String)] = [
        (.def,     "def"),
        (.now,     "now"),
        (.edge,    "edge"),
        (.compact, "compact"),
        (.parens,  "parens"),
        (.expand,  "expand"),
    ]

    public var description: String {
        let result: [String] = Self.debugDescriptions.filter { contains($0.0) }.map { $0.1 }
        let joined = result.joined(separator: ", ")
        return "\(joined)"
    }
}

