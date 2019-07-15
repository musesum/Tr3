//
//  Tr3.swift
//  Par
//
//  Created by warren on 3/7/19.
//
import Par

public class Tr3: Hashable {

    var id = Visitor.nextId()

    public var name = ""
    public var parent: Tr3? = nil      // parent tr3
    public var children = [Tr3]()      // expanded tr3 from  wheres~tr3

    var pathrefs: [Tr3]?        // b in `a.b <-> c` for `a{b{c}} a.b <-> c
    var passthrough = false      // does not have a Tr3Val yet, so pass through events
    
    public var val: Tr3Val? = nil

    var edgeDefs = Tr3EdgeDefs()   // for a<-(b.*++), this saves "++" and "b.*)
    var tr3Edges = [Tr3Edge]() // some edges are defined by another Tr3

    var callbacks = [Tr3Visitor]() // during activate callback and return with Tr3Val ((Tr3Val?)->(Tr3Val?))
    var type = Tr3Type.unknown
    var bound = false // after binding edges

    public func hash(into hasher: inout Hasher) {  hasher.combine(id)  }

    public static func == (lhs: Tr3, rhs: Tr3) -> Bool { return lhs.id == rhs.id  }

    public convenience init(_ name_:String,_ type_:Tr3Type = .name) {
        self.init()
        name = name_
        type = type_
    }

    public convenience init(deepcopy: Tr3, parent parent_:Tr3) {

        self.init()
        parent = parent_
        name = deepcopy.name
        type = deepcopy.type
        for child in deepcopy.children {
            children.append(Tr3(deepcopy: child, parent: self))
        }
        passthrough = deepcopy.passthrough
        val         = deepcopy.val?.copy() ?? nil
        edgeDefs    = deepcopy.edgeDefs.copy()
    }
    public convenience init(with val_: Tr3Val) { self.init() ; val = val_.copy() }

    public func makeTr3From(parAny:ParAny) -> Tr3 {

        if let value = parAny.value {
            return Tr3(value)
        }
        return self
    }

    ///  attach to only deepest children
    ///
    ///      attach z to a { b c }       ⟹  a { b { z } c { z } }
    ///      attach z to a { b { c } }   ⟹  a { b { c { z } } }
    ///
    ///  - parameter tr3: The parent Tr3, which may be a leaf to attach or has children to scan deeper.
    ///
    ///  - parameter visitor: the same "_:_" clone may be attached to multiple parent before consolication.
    ///     So, use visitor pattern to avoid multiple visits
    public func attachDeep(_ tr3:Tr3, _ visitor: Visitor) {
        if visitor.newVisit(id) {
            if children.count == 0 {
                tr3.parent = self
                children.append(tr3)
            }
            else {
                for child in children {
                    child.attachDeep(tr3,visitor)
                }
            }
        }
    }

    /// attach future children to parent's children, for a many:many relationship
    ///
    ///      a { b c } : { d e }      ⟹  a { b { d e } c { d e } }
    ///      a { b { c } } : { d e }  ⟹  a { b { c { d e } } }
    ///
    /// initial step is to create a placeholder _:_ for { d e }
    ///
    ///      a { b c } : _:_        ⟹  a { b { _:_ } c { _:_ } }
    ///
    /// after subsequent parsing fills _:_ with { d e }, then bind
    ///
    ///      a { b {_:_{d e}} c {_:_{d e}}}  ⟹  a { b { d e } c { d e } }
    public func makeMany() -> Tr3 {
        let many = Tr3("_:_",.many)
        attachDeep(many,Visitor(0))
        return many
    }

    public func addChild(_ n:ParAny,_ type_:Tr3Type)  -> Tr3 {

        if let value = n.next.first?.value {

            let child = Tr3(value,type_)
            children.append(child)
            child.parent = self
            return child
        }
        return self
    }
    
    public func makeChild(_ name:String = "") -> Tr3 {
        let child = Tr3(name)
        child.parent = self
        children.append(child)
        return child
    }

    public func parentPath(_ depth:Int = 2, withId:Bool = false) -> String {
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

    /// override old ternary with new value
    public func overideEdgeTernary(_ tern_:Tr3ValTern) -> Bool {

        for edgeDef in edgeDefs.edgeDefs {
            if let valPath = edgeDef.defVal as? Tr3ValPath,
                valPath.path == tern_.path {

                edgeDef.defVal = tern_.copy()

                return true
            }
        }
        return false
    }
    /// add ternary to array of edgeDefs
    public func addEdgeTernary(_ tern_:Tr3ValTern, copyFrom: Tr3? = nil) {

        if let lastEdgeDef = edgeDefs.edgeDefs.last {
            
            if let lastTern = lastEdgeDef.defVal as? Tr3ValTern {
                lastTern.deepAddVal(tern_)
            }
            else {
                lastEdgeDef.defVal = tern_
                Tr3ValTern.ternStack.append(tern_)
            }
        }
            // copy edgeDef from search z in
        else if let copyEdgeDef = copyFrom?.edgeDefs.edgeDefs.last {

            let newEdgeDef = Tr3EdgeDef(with:copyEdgeDef)
            edgeDefs.edgeDefs.append(newEdgeDef)
            newEdgeDef.defVal = tern_
            Tr3ValTern.ternStack.append(tern_)
        }
        else {

            print("*** \(#function) no edgeDefs to add edge")
        }
    }


}

