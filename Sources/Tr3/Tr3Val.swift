//  Tr3Val.swift
//
//  Created by warren on 3/8/19.

import Foundation
import CoreGraphics
import Par

protocol Tr3ValScriptProtocol {
    func printVal() -> String
    func scriptVal(parens: Bool, session: Bool, expand: Bool) -> String
}
protocol Tr3ValProtocal {

    func copy() -> Tr3Val
    func setVal(_ from: Any?, _ option: Tr3SetOptions?)
    func getVal() -> Any
}
public class Tr3Val: Comparable {

    var id = Visitor.nextId()
    var tr3: Tr3  // tr3 that declared and contains this value
    var valFlags = Tr3ValFlags(rawValue: 0) // which combination of the following?

    public static func == (lhs: Tr3Val, rhs: Tr3Val) -> Bool {
        return lhs.valFlags == rhs.valFlags
    }
    public static func < (lhs: Tr3Val, rhs: Tr3Val) -> Bool {
        return lhs.id < rhs.id
    }

    init(_ tr3: Tr3) {
        self.tr3 = tr3
    }
    init(with tr3Val: Tr3Val) {
        tr3 = tr3Val.tr3
        valFlags = tr3Val.valFlags
    }
    func parse(string: String) -> Bool {
        print("Tr3Val parsing:" + string)
        return true
    }

    func copy() -> Tr3Val {
        return Tr3Val(with: self)
    }
    func addFlag(_ flag_: Tr3ValFlags) {
        valFlags.insert(flag_)
    }
    public func setVal(_ from: Any?, _ option: Tr3SetOptions? = nil) {
        assertionFailure("🚫 setVal needs override")
    }
    public func getVal() -> Any {
        assertionFailure("🚫 getVal needs override")
    }
}

extension Tr3Val: Tr3ValScriptProtocol {
    // print current state "2" in `a:(0…9=2)`
    @objc dynamic func printVal() -> String {
        return ""
    }
    // print internal connections "a╌>w", "b╌>w", "c╌>w" in  `w<-(a ? 1 : b ? 2 : c ? 3)`
    @objc dynamic func scriptVal(parens: Bool = true,
                                 session: Bool = false,
                                 expand: Bool = false) -> String {
        return " "
    }
}
