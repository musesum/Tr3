//
//  Tr3Flags.swift
//  Par
//
//  Created by warren on 5/9/19.
//

import Foundation

public struct Tr3FindFlags: OptionSet {

    public let rawValue: Int
    
    public static let parents  = Tr3FindFlags(rawValue: 1 << 0) // 1 General type Tr3ValScalar
    public static let children = Tr3FindFlags(rawValue: 1 << 1) // 2 eneral type Tr3ValScalar
    public static let makePath = Tr3FindFlags(rawValue: 1 << 2) // 4 eneral type Tr3ValScalar

    public init(rawValue:Int) { self.rawValue = rawValue }
}

public struct Tr3SetOptions: OptionSet {

    public let rawValue: Int

    public static let sneak    = Tr3SetOptions(rawValue: 1 << 0) // : 1 quietly set value, no trigger
    public static let activate = Tr3SetOptions(rawValue: 1 << 1) // : 2 trigger event
    public static let cache    = Tr3SetOptions(rawValue: 1 << 2) // : 4 cache for next frame update
    public static let changed  = Tr3SetOptions(rawValue: 1 << 3) // : 8 bang only when changed
    public static let create   = Tr3SetOptions(rawValue: 1 << 4) // :16 create a new value

    public init(rawValue:Int) { self.rawValue = rawValue }
}
