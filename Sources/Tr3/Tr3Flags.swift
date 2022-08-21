//  Tr3Flags.swift
//
//  Created by warren on 5/9/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

public struct Tr3FindFlags: OptionSet {

    public static let parents  = Tr3FindFlags(rawValue: 1 << 0) // General type Tr3ValScalar
    public static let children = Tr3FindFlags(rawValue: 1 << 1) // General type Tr3ValScalar
    public static let makePath = Tr3FindFlags(rawValue: 1 << 2) // General type Tr3ValScalar

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
}

public struct Tr3SetOptions: OptionSet {

    public static let activate = Tr3SetOptions(rawValue: 1 << 0) // trigger event
    public static let sneak    = Tr3SetOptions(rawValue: 1 << 1) // quietly set value, no trigger
    public static let cache    = Tr3SetOptions(rawValue: 1 << 2) // cache for next frame update
    public static let changed  = Tr3SetOptions(rawValue: 1 << 3) // bang only when changed

    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
}
