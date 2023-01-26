//  Tr3Val.swift
//
//  Created by warren on 3/8/19.

import Foundation
import CoreGraphics
import MuTime
import Par

protocol Tr3ValProtocal {

    func copy() -> Tr3Val
    func setVal(_ from: Any?, _ option: Tr3SetOptions?) -> Bool
    func getVal() -> Any
}

open class Tr3Val: Comparable {

    var id = -Visitor.nextId()
    var valFlags = Tr3ValFlags(rawValue: 0) // which combination of the following?
    var name: String

    public var tr3: Tr3  // tr3 that declared and contains this value

    public static func == (lhs: Tr3Val, rhs: Tr3Val) -> Bool {
        return lhs.valFlags == rhs.valFlags
    }
    public static func < (lhs: Tr3Val, rhs: Tr3Val) -> Bool {
        return lhs.id < rhs.id
    }

    init(_ tr3: Tr3, _ name: String) {
        self.tr3 = tr3
        self.name = name
    }
    init(with: Tr3Val) {
        self.tr3 = with.tr3
        self.name = with.name
        self.valFlags = with.valFlags
    }
    func parse(string: String) -> Bool {
        print("Tr3Val parsing:" + string)
        return true
    }


    func addFlag(_ flag_: Tr3ValFlags) {
        valFlags.insert(flag_)
    }

    // print current state "2" in `a:(0…9=2)`
    public func printVal() -> String {
        return ""
    }
   // print internal connections "a╌>w", "b╌>w", "c╌>w" in  `w<-(a ? 1 : b ? 2 : c ? 3)`
  public func scriptVal(_ scriptFlags: Tr3ScriptFlags = [.parens]) -> String {
       return " "
   }

    public func hasDelta() -> Bool {
        return false
    }


    func copy() -> Tr3Val {
        return Tr3Val(with: self)
    }
    public func setVal(_ from: Any?,
                       _ visitor: Visitor,
                       _ option: Tr3SetOptions? = nil) -> Bool {

        assertionFailure("🚫 setVal needs override")
        return false
    }

    public func getVal() -> Any {
        assertionFailure("🚫 getVal needs override")
    }

}
