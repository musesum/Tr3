//
//  Tr3+Find.swift
//  Par
//
//  Created by warren on 4/8/19.
//

import Foundation
import Par // whitespace

extension Tr3 {

    // b.c a { b { c {c1 c2} d {d1 d2} } b.c : c3 }
    func willMerge(with tr3:Tr3) -> Bool {
        if tr3 == self {
            return true
        }
        for child in tr3.children {
            if child == self {
                return true
            }
        }
        return parent?.willMerge(with:tr3) ?? false
    }

    /// previously declared Tr3 has a ":"
    ///
    ///  What follows a ":" is either a:
    ///   1) new node to add to tree,
    ///   2) new path synthesized from current location, or
    ///   3) one or more nodes to override
    ///
    /// for example
    ///
    ///     /**/ a { b { c { c1 c2 } d { d1 d2 } } b.c : c3 } ⟹
    ///     √  { a { b { c { c1 c2 c3 } d { d1 d2 } } } }
    ///
    ///     /**/ a { b { c { c1 c2 } d { d1 d2 } } b.c : b.d } ⟹
    ///     √  { a { b { c { c1 c2 d1 d2 } d { d1 d2 } } } }
    func mergeDuplicate(_ merge:Tr3) {

        var foundDuplicate = false

        for sibling in children {

            if sibling.id != merge.id,
                sibling.name == merge.name {

                foundDuplicate = true
                merge.type = .remove

                sibling.val = merge.val
                sibling.edgeDefs = merge.edgeDefs
                // e in `a { b { c d } } a { e }`
                for mergeChild in merge.children {
                    sibling.mergeDuplicate(mergeChild)
                }
            }
        }

        if foundDuplicate {
            children = children.filter { $0.type != .remove }
        }
        else {
            children.append(merge)
        }
    }

    func bindMany() -> [Tr3] {

        var result = [Tr3]()
        for child in children {
            // add copy of copy's child
            let copy = Tr3(deepcopy: child, parent: self)
            result.append(copy)
        }
        return result
    }
    func scriptChildren(_ children:[Tr3]) -> String {
        var script = "["
        var delim = ""
        for child in children {
            script += delim + child.name
            delim = " "
        }
        script += "]"
        return script
    }

    func bindProto() -> [Tr3] {

        if let found = bindFindPath() {

            if  found.count == 1,
                found.first?.id == id,
                self.children.isEmpty {

                type = .name
                return [self]
            }
            /// :_c in `a.b { _c { c1 c2 } c { d e }:_c }`
            if found.count > 0, let parent = parent {

                var newChildren = [Tr3]()
                for foundi in found {
                    for foundChild in foundi.children {
                        let copy = Tr3(deepcopy: foundChild, parent: parent)
                        newChildren.append(copy)
                    }
                }
                return newChildren
            }
        }
        // :e in `a { b { c {c1 c2} d } } a : e`
        return [self]
    }

    /// either merge a new Tr3 or deepCopy a reference to existing Tr3
    func mergeOrCopy(_ found:[Tr3]) -> [Tr3] {

        var results = [Tr3]()

        for foundi in found {
            // is adding or appending with a direct ancestor
            if let parent = parent,
                foundi.willMerge(with:parent) {
                // b.c in `a { b { c {c1 c2} d } b.c : c3 }`
                for child in children {
                    foundi.mergeDuplicate(child)
                }
            }
            else {
                // b.d in `a { b { c {c1 c2} d {d1 d2} } b.c : b.d  }`
                let copy = Tr3(deepcopy: foundi, parent: self)
                results.append(copy)
            }
        }
        return results
    }

    func bindFindPath() -> [Tr3]? {

        let found = findAnchor(name, [.parents,.children])

        if found.count == 1, found.first?.id == id,
            self.children.isEmpty {

            type = .name
            return [self]
        }

        if found.count > 0 {
            if edgeDefs.edgeDefs.isEmpty {
                // b.c in `a { b { c {c1 c2} d } b.c { c3 } }`
                let results = mergeOrCopy(found)
                return results
            }
            else {
                // a.b in `a { b { c } }  a.b <-> c`
                pathrefs = found
                return [self]
            }
        }
        return nil
    }
    func bindMakePath() -> [Tr3] {

        let found = findPathTr3s(name, [.parents,.children])

        type = .remove
        // no anchor to start from so make path starting from root
        if found.isEmpty {
            if let pathChain = makePath(name,children) {
                // e.f, a.b.c.d in `a.b.c.d { e.f }` -- in that order
                return [pathChain]
            }
            return found
        }
        else {
            // b.e in `a { b { c d } b.e }`
            // e in `a { b { c {c1 c2} d } } a : e`
            return [self]
        }
    }
    func bindPath() -> [Tr3] {
        if let found = bindFindPath() {
            return found
        }
        else {
            return bindMakePath()
        }
    }


    /// found unique name
    func bindName() -> [Tr3] {

        if let parent = parent {

            for sibling in parent.children {
                // sibling is candidate, no need to search anymore
                if sibling.id == id {
                    return [self]
                }
                // found sibling with same name so merge
                if sibling.name == name {
                    parent.mergeDuplicate(self)
                    return []
                }
            }
        }
        // didn't find matching sibling so is unique
        return [self]
    }
    /// find duplicates in children and merge their children
    /// a,a in `a.b { c d } a.e { f g }`
    func mergeChildren(_ kids :[Tr3]) {

        func mergeDuplicate(_ prior:Tr3,_ kid:Tr3) {
            // override old value with new value if it exists
            if let val = kid.val { prior.val = val }
            // add new edge definitions
            prior.edgeDefs.merge(kid.edgeDefs)
            // append children
             prior.children.append(contentsOf: kid.children)

            // recursively filter out duplicate child additions
            //prior.mergeChildren(kid.children)
            //prior.children = prior.children.filter { $0.type != .remove }

            prior.bindChildren()
            kid.type = .remove
        }
        // some children were copied or promoted so fix their parent
        var nameTr3 = [String:Tr3]()
       
        var merged = false
        for kid in kids {

            kid.parent = self ///???

            if let prior = nameTr3[kid.name] {
                mergeDuplicate(prior, kid)
                merged = true
            }
            else {
                nameTr3[kid.name] = kid
            }
        }
        if merged {
            bindTopDown()
        }
    }

    func bindChildren() {

        // add clones to children with
        var kids = [Tr3]()

        if name == Tr3.debugName {
            print(name)
        }
        for child in children {

            switch child.type {

            case .path:   kids.append(contentsOf: child.bindPath())
            case .many:   kids.append(contentsOf: child.bindMany())
            case .proto:  kids.append(contentsOf: child.bindProto())
            case .name:   kids.append(contentsOf: child.bindName())

            case .remove: break

            default:      kids.append(child)
            }
        }
        mergeChildren(kids)
        children = kids.filter { $0.type != .remove }
    }

    func bindBottomUp() {

        // depth first bind from bottom up
        for child in children {
            if child.children.count > 0 {
                child.bindBottomUp()
            }
        }
        bindChildren()
    }
    /// split path into a solo child that
    /// inherits original's children and edges
    ///
    ///     a.b:0 <- c { d } // becomes
    ///     a { b:0 <- c { d } }
    ///
    func spawnChild(from suf: String) -> Tr3 {

        let newTr3 = Tr3(String(suf))   // make new tr3 from path suffix
        newTr3.children = children      // transfer children to new tr3
        newTr3.parent = self
        for child in newTr3.children {
            child.parent = newTr3
        }

        newTr3.edgeDefs = edgeDefs
        edgeDefs = Tr3EdgeDefs()

        newTr3.tr3Edges = tr3Edges
        tr3Edges = [String:Tr3Edge]()

        children = [newTr3]             // make newTr3 my only child
        newTr3.val = val ; val = nil    // transfer my value to newTr3
        return newTr3
    }
    /// recursively split path into solo child, grand, etc
    ///
    ///     a.b.c         // becomes after 1st pass:
    ///     a { b.c }     // becomes after 2nd pass:
    ///     a { b { c } } // as final result
    ///
    func divideAndContinue(_ index:Int) {

        if index > 0 {

            let prefix = name.prefix(index)
            let sufCount = name.count-index-1

            if sufCount > 0 { // split `a.b.c` into `a`, `b.c`

                let suffix = name.suffix(sufCount) // make suffix substring
                let child = spawnChild(from: String(suffix))

                name = String(prefix)   // change name to only prefix
                type = .name            // change my type to .name
                child.expandDotPath()   // continue with `b.c`
            }
            else { // special case with `a.`

                name = String(prefix)   // trim trailing .
                type = .name            // change my type to .name
            }

        }
    }
    /// Expand pure path `a.b.c` into `a { b { c } }` --
    /// do no allow search paths `a~b` or prototypes `a:b`
    ///
    /// - note: May override public to debug specific paths.
    ///
    @discardableResult
    public func expandDotPath() -> Bool{

        var index = 0
        if name.contains("~") { return false }
        for s in name {
            switch s {
            case "~": return false
            case ":": return false
            case ".":

                divideAndContinue(index)
                return true

            default: index += 1
            }
        }
        return false
    }
    /// first pass convert `a.b.c` into `a { b { c } }`
    func bindTopDown() {

        if type != .proto,
            expandDotPath(),
            let parent = parent {

            for sibling in parent.children {
                if  sibling.name == name,
                    sibling.id != id {

                    parent.mergeDuplicate(self)
                }
            }
        }
        for child in children {
            child.bindTopDown()
        }
    }
    func bindTopDownOld() {
        if type != .proto {
            expandDotPath()
        }
        for child in children {
            child.bindTopDown()
        }
    }
    /// activate or deactivate edges for ternaries 
    func bindTernaries() {
        for edgeDef in edgeDefs.edgeDefs {
            
            if  let ternVal = edgeDef.ternVal,
                let leftTr3 = edgeDef.edges.values.first?.leftTr3 {
                
                ternVal.recalc(leftTr3, self, .sneak , Visitor(0)) 
            }
        }
        for child in children {
            child.bindTernaries()
        }
    }
    func bindEdges() {
        edgeDefs.bindEdges(self)
        for child in children {
            child.bindEdges()
        }
    }
    /// 2nd a.b in `a.b { c d } a.e:a.b { f g }`
    ///
    /// - note: Needs forward pass for prototypes that refer to unexpanded paths.
    ///
    /// Because expansion is bottom up, the first a.b in:
    ///
    ///     a.b { c d } a.e:a.b { f g }
    ///
    /// has not been been expanded, when encountering the second a.b.
    /// So, deeper a.b was deferred until this forward pass,
    /// where first a.b has finally expanded and can now bind
    /// its children.
    ///
    func bindPrototypes() {

        var hasProtoChild = false
        // depth first bind from bottom up
        for child in children {
            if child.children.count > 0 {
                child.bindPrototypes()
            }
            if child.type == .proto {
                hasProtoChild = true
            }
        }
        if hasProtoChild {
            bindChildren()
        }
    }
    ///
    func bindDefaults() {
        if let val = val as? Tr3ValTuple {
            val.setDefaults()
        }
        for child in children {
            child.bindDefaults()
        }
    }

    /// bind root of tree and its subtree graph
    
    public func bindRoot() {

        func log(_ num:Int) {
            if      Tr3.dumpScript { print(dumpScript() + " // \(num)") }
            else if Tr3.makeScript { print(makeScript() + " // \(num)") }
        }
        bindTopDown()     ; log(1)
        bindBottomUp()    ; log(2)
        bindPrototypes()  ; log(3)
        bindEdges()       ; log(4)
        bindTernaries()   ; log(5)
        bindDefaults()
    }
}
