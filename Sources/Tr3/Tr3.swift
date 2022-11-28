//  Tr3.swift
//
//  Created by warren on 3/7/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par

public class Tr3: Hashable {

    public static var LogBindScript = false // debug while binding
    public static var LogMakeScript = false // debug while binding

    public var id = Visitor.nextId()

    public var name = ""
    public var parent: Tr3? = nil   // parent tr3
    public var children = [Tr3]()   // expanded tr3 from  wheres˚tr3
    public var comments = Tr3Comments()

    var time = TimeInterval(0)  // UTC time of last change time
    var changes: UInt = 0       // temporary count of changes to descendants

    var pathrefs: [Tr3]?        // b in `a.b <-> c` for `a{b{c}} a.b <-> c
    var passthrough = false /// does not have its own Tr3Val, so pass through events
    
    public var val: Tr3Val? = nil
    var cacheVal: Any? = nil        // cached value is drained

    var edgeDefs = Tr3EdgeDefs()    // for a<-(b.*++), this saves "++" and "b.*)
    var tr3Edges = [String: Tr3Edge]() // some edges are defined by another Tr3

    var closures = [Tr3Visitor]()  // during activate call a list of closures and return with Tr3Val ((Tr3Val?)->(Tr3Val?))
    public var type = Tr3Type.unknown
    var copied = [Tr3]()

    public func hash(into hasher: inout Hasher) { hasher.combine(id) }

    public static func == (lhs: Tr3, rhs: Tr3) -> Bool { return lhs.id == rhs.id }

    public convenience init(_ name_: String, _ type_: Tr3Type = .name) {
        self.init()
        name = name_
        type = type_
    }

    public convenience init(deepcopy from: Tr3, parent: Tr3) {

        self.init()
        self.parent = parent
        name = from.name
        type = from.type
        for fromChild in from.children {
            let newChild = Tr3(deepcopy: fromChild, parent: self)
            children.append(newChild)
        }
        passthrough = from.passthrough
        val         = from.val?.copy() ?? nil
        edgeDefs    = from.edgeDefs.copy()
        comments    = from.comments
    }
    public convenience init(with val_: Tr3Val) { self.init() ; val = val_.copy() }

    public func makeTr3From(parItem: ParItem) -> Tr3 {

        if let value = parItem.value {
            return Tr3(value)
        }
        return self
    }

    /** attach to only deepest children

        attach z to a { b c }       ⟹  a { b { z } c { z } }
        attach z to a { b { c } }   ⟹  a { b { c { z } } }

    - Parameters:
        - tr3: The parent Tr3, which may be a leaf to attach or has children to scan deeper.

        - visitor: the same "_:_" clone may be attached to multiple parent before consolication.
     */
    func attachDeep(_ tr3: Tr3, _ visitor: Visitor) {
        if visitor.newVisit(id) {
            if children.count == 0 {
                tr3.parent = self
                children.append(tr3)
            }
            else {
                for child in children {
                    child.attachDeep(tr3, visitor)
                }
            }
        }
    }

    /** attach future children to parent's children, for a many:many relationship

         a { b c } : { d e }      ⟹  a { b { d e } c { d e } }
         a { b { c } } : { d e }  ⟹  a { b { c { d e } } }

    initial step is to create a placeholder _:_ for { d e }

         a { b c } : _:_        ⟹  a { b { _:_ } c { _:_ } }

    after subsequent parsing fills _:_ with { d e }, then bind

         a { b {_:_{d e}} c {_:_{d e}}}  ⟹  a { b { d e } c { d e } }
     */
    public func makeMany() -> Tr3 {
        let many = Tr3("_:_", .many)
        attachDeep(many, Visitor(0))
        return many
    }

    public func addChild(_ parItem: ParItem, _ type_: Tr3Type)  -> Tr3 {

        if let value = parItem.nextPars.first?.value {

            let child = Tr3(value, type_)
            children.append(child)
            child.parent = self
            return child
        }
        return self
    }
    
    public func makeChild(_ name: String = "") -> Tr3 {
        let child = Tr3(name)
        child.parent = self
        children.append(child)
        return child
    }

    public func addClosure(_ closure: @escaping Tr3Visitor) {
        closures.append(closure)
    }
    public func parentPath(_ depth: Int = 2, withId: Bool = false) -> String {
        var path = name
        if withId { path += "." + String(id) }
        if depth > 1, let parentPath =  parent?.parentPath(depth-1) {
            path = parentPath + "." + path
        }
        return path
    }

    public func getRoot() -> Tr3 {
        if let parent = parent {
            return parent.getRoot()
        }
        return self
    }

    public func parseTime(_ time: Double) {
        //TODO: parse and print
    }
    public func parseHash(_ time: Double) {
        //TODO: parse and print
    }
    
}

