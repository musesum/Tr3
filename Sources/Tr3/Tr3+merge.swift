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

    /// previously declared Tr3 has a ":", which indicates that what follows refers to either a:
    ///   1) new node to add to tree,
    ///   2) new path synthesized from current location, or
    ///   3) one or more nodes to override
    ///
    /// for example
    ///
    ///        a { b { c { c1 c2 } d { d1 d2 } } b.c : c3 } ⟹
    ///    √ { a { b { c { c1 c2 c3 } d { d1 d2 } } } }
    ///
    ///        a { b { c { c1 c2 } d { d1 d2 } } b.c : b.d } ⟹
    ///    √ { a { b { c { c1 c2 d1 d2 } d { d1 d2 } } } }
    func mergeDuplicate(_ merge:Tr3) {

        var foundDuplicate = false

        for sibling in children {

            if sibling.id != merge.id,
                sibling.name == merge.name {

                foundDuplicate = true
                type = .remove

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

    func LogTr3Merge(_ str:String,_ terminator: String = " ") {
        //print(str,terminator:terminator)
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
                LogTr3Merge("9:" + name)
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
                LogTr3Merge(scriptChildren(newChildren))
                return newChildren
            }
        }
        // :e in `a { b { c {c1 c2} d } } a : e`
        LogTr3Merge("C:" + name)
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
                LogTr3Merge("4:" + (results.first?.name ?? "??"))
                return results
            }
            else {
                // a.b in `a { b { c } }  a.b <-> c`
                pathrefs = found
                LogTr3Merge("5:" + self.name)
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
                LogTr3Merge("6:" + pathChain.name)
                return [pathChain]
            }
            LogTr3Merge("7:" + (found.first?.name ?? "??"))
            return found
        }
        else {
            // b.e in `a { b { c d } b.e }`
            // e in `a { b { c {c1 c2} d } } a : e`
            LogTr3Merge("8:" + self.name)
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
                    LogTr3Merge("1:" + self.name)
                    return [self]
                }
                // found sibling with same name so merge
                if sibling.name == name {
                   parent.mergeDuplicate(self)
                     LogTr3Merge("2:" + self.name)
                    return []
                }
            }
        }
        // didn't find matching sibling so is unique
        LogTr3Merge("3:" + self.name)
        return [self]
    }
    /// find duplicates in children and merge their children
    /// a,a in `a.b { c d } a.e { f g }`
    func mergeChildren(_ children:[Tr3]) {
        // some children were copied or promoted so fix their parent
        var nameTr3 = [String:Tr3]()
        for child in children {
            child.parent = self
            if let prior = nameTr3[child.name] {
                prior.val = child.val // override value but keep children order
                prior.children.append(contentsOf: child.children)
                mergeChildren(prior.children)
                prior.children = prior.children.filter {$0.type != .remove }
                child.type = .remove
            }
            else {
                nameTr3[child.name] = child
            }
        }
    }

    func bindChildren() {
        // add clones to children with
        var allChildren = [Tr3]()

        for child in children {

            switch child.type {

            case .path:   allChildren.append(contentsOf: child.bindPath())
            case .many:   allChildren.append(contentsOf: child.bindMany())
            case .proto:  allChildren.append(contentsOf: child.bindProto())
            case .name:   allChildren.append(contentsOf: child.bindName())

            case .remove: break

            default:      allChildren.append(child)
            }
        }
        LogTr3Merge("","\n")
        mergeChildren(allChildren)
        children = allChildren.filter { $0.type != .remove }
    }

    func bindDeepTr3() {

        // depth first bind from bottom up
        for child in children {
            if child.children.count > 0 {
                child.bindDeepTr3()
            }
        }
       bindChildren()
    }

    /// activate or deactivate edges for ternaries 
    func bindTerns() {
        for edgeDef in edgeDefs.edgeDefs {
            
            if  let ternVal = edgeDef.defVal as? Tr3ValTern,
                let leftTr3 = edgeDef.edges.first?.leftTr3 {
                
                ternVal.recalc(leftTr3, self, .sneak , Visitor(0)) 
            }
        }
        for child in children {
            child.bindTerns()
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
    func bindUnexpandedProto() {

        var hasProtoChild = false
        // depth first bind from bottom up
        for child in children {
            if child.children.count > 0 {
                child.bindUnexpandedProto()
            }
            if child.type == .proto {
                hasProtoChild = true
            }
        }
        if hasProtoChild {
            bindChildren()
        }
    }
    /// while loading multiple files, binding will revisit previously bound subgraph.
    /// So, skip binding prior subgraph to prevent creating duplicate edges.
    func bindGraph() {
        bound = true
        for child in children {
            child.bindGraph()
        }
    }
    /// bind root of tree and its subtree graph
    public func bindRoot() {
        bindDeepTr3()
        bindUnexpandedProto()
        bindEdges()
        bindTerns()
        bindGraph()
    }
}
