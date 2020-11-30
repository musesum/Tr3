//  Tr3+find.swift
//
//  Created by warren on 5/2/19.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

import Foundation


extension Tr3 {

    // returns a.b in `a { b { c } } a˚b`
    // returns a.b.c in `a { b { c } } a˚c`
    // returns a.b1.c,a.b2.c in `a { b1 { c } b2 { c } } a˚c`

    // ? in `˚`   // undefined
    // a in `˚a`  // add if matches b and stop, otherwise continue
    // a in `˚˚a` // add if matches b, always continue
    // _ in `˚˚`  // add in all cases, always continue
    // a in `˚.a` // add if matches b and no children and stop, otherwise continue
    // _ in `˚.`  // add if no children, otherwise continue

    func getDegreeTr3s(_ wildcard: String, _ suffix: String) -> [Tr3] {

        let greedy = wildcard == "˚˚"
        let leafy = wildcard == "˚."
        var found = [Tr3]()

        func findDeeper() {
            for child in children {
                let foundChild = child.getDegreeTr3s(wildcard,suffix)
                found.append(contentsOf: foundChild)
            }
        }
        // ────────────── begin ──────────────
        // do not incude ˚˚ in `˚˚ <-> ..`
        if type == .path {
            return []
        }
        else if suffix.isEmpty {                        // for a { b { c } }

            if greedy {                                 //  a,b,c in ˚˚˚
                found.append(self)
                findDeeper()
            }
            if leafy  {
                if children.isEmpty { return [self] }   // c   in ˚.
                else                { findDeeper() }    // a,b in ˚.
            }
            return found
        }
        else {
            var found2 = [Tr3]()
            let (prefix2,wild2,suffix2) = suffix.splitWild(".*˚")
            if name == prefix2 {
                if leafy {
                    if children.isEmpty { found = [self] }   // c in ˚.c
                    else                { return [] }       // b in ˚.b
                }
                else {
                    found = [self]                          // b in ˚b,˚˚b
                    if greedy { findDeeper() }
                }
            }
            else {                                          // !b in ˚b,˚˚b
                findDeeper()
            }
            for foundi in found {
                let foundi2 = foundi.getWildSuffix(wild2, suffix2, .children)
                found2.append(contentsOf: foundi2)
            }
            return found2
        }
    }


    // returns a in `a.b.c <- ...`
    func getDotParent(_ count: Int) -> Tr3? {
        if count < 1 {
            return self
        }
        else if let parent = parent {
            return parent.getDotParent(count-1)
        }
        else {
            return nil
        }
    }

    // `..`, `...`, `..a`
    func getNearDots(_ wildcard: String,_ suffix: String,_ findFlags: Tr3FindFlags) -> [Tr3] {
        if wildcard == ".*" { return children }
        if let parent = getDotParent(wildcard.count-1) {
            let nextFlags = findFlags.intersection([.parents,.children,.makePath])
            return parent.findPathTr3s(suffix,nextFlags)
        }
        else {
            return []
        }
    }

    /// find preexisting item 
    public func findAnchor(_ path: String, _ findFlags: Tr3FindFlags) -> [Tr3] {

        let (prefix,wildcard,suffix) = path.splitWild(".*˚")

        let deeperFlags = findFlags.intersection([.children,.makePath])


        if name == prefix, type == .name {
            return findPathTr3s(wildcard + suffix, [.children])
        }
        else if name == prefix, wildcard == "", type == .copier, let parent = parent {
            return parent.findPathTr3s(path, findFlags)
        }
        else if prefix == "", let parent = parent {
            return parent.findPathTr3s(wildcard + suffix, deeperFlags)
        }
        else if findFlags.contains(.children) {
            for child in children {
                if child.name == prefix, child.type == .name {
                    return child.findPathTr3s(wildcard + suffix, deeperFlags)
                }
            }
        }
        // still no match, so maybe search parents
        if findFlags.contains(.parents) {
            if let parent = parent {
                return parent.findAnchor(path, findFlags)
            }
            else if prefix == "" {
                return findPathTr3s(wildcard + suffix, findFlags)
            }
        }
        return []
    }

    func findPrefixTr3(_ prefix: String, _ findFlags: Tr3FindFlags) -> Tr3? {
        if prefix == ""   {
            return self }
        if name == prefix {
            return self }
        if findFlags.contains(.children) {
            for child in children {
                if child.type == .remove { continue }
                if child.type == .copier { continue }
                if child.name == prefix {
                    return child }
            }
        }
        // still no match, so maybe search parents
        if findFlags.contains(.parents),
            let parent = parent {
            return parent.findPrefixTr3(prefix, findFlags)
        }
        return nil
    }

    func getWildSuffix(_ wildcard: String,_ suffix: String, _ findFlags: Tr3FindFlags) -> [Tr3] {
        // after finding starting point, only search children
        // and maybe create a tr3s, when specified in some cases.
        let nextFlags = findFlags.intersection([.children,.makePath])

        func getWild(tr3: Tr3) -> [Tr3] {

            switch wildcard.first {
            case ".": return tr3.getNearDots(wildcard, suffix, nextFlags)
            case "˚": return tr3.getDegreeTr3s(wildcard, suffix)
            default:  return [tr3]
            }
        }

        var found = [Tr3]()
        if let pathrefs = pathrefs {
            for pathref in pathrefs {
                found.append(contentsOf:  getWild(tr3: pathref))
            }
        }
        else {
            found.append(contentsOf:  getWild(tr3: self))
        }
        return found
    }

    func findPathTr3s(_ path: String,_ findFlags: Tr3FindFlags) -> [Tr3] {

        let (prefix,wildcard,suffix) = path.splitWild(".*˚")

        func isStarMatch() -> Bool {

            if wildcard.first == "*",
                (name.hasPrefix(prefix) || prefix == "") {
                // get b in `a*b.c`
                let (suffix2,_,_) = suffix.splitWild(".*˚")
                if name.hasSuffix(suffix2) || suffix2 == "" {
                    // a in `a*`        => [self]
                    // abacab in `a*b`  => [self]
                    // NOT aba in `a*b` => []
                    // TODO `a*b.whatever` is undefined
                    return true
                }
            }
            return false
        }

        // ────────────── begin ──────────────

        if isStarMatch() {
            return [self]
        }
        else if let prefixTr3 = findPrefixTr3(prefix,findFlags) {
            let found = prefixTr3.getWildSuffix(wildcard, suffix, findFlags)
            if found.count > 0 { return found }
        }

        // still no match, so maybe make a new tr3
        // make a.b, c.d in in `a.b { c.d }`
        // make e.f but not g.h in `e.f <- g.h`
        if findFlags.contains(.makePath) {

            if !prefix.isEmpty {
                // cannot make b in `a˚b` or `a.*.b`
                if path.contains("˚") || path.contains("*") {
                    return []
                }

                var found = [Tr3]()
                let anchors = findAnchor(prefix, [.parents,.children])
                for anchori in anchors {
                    if let foundi = anchori.makePath(suffix, nil) {
                        found.append(foundi)
                    }
                }
                return found
            }
        }
        return []
    }

    /// expand path to new tr3s
    ///
    ///     a.b.c.d { e.f } ⟹
    ///     √ { a { b { c { d { e { f } } } } } }
    ///
    func makePath(_ path: String,_ head: Tr3?) -> Tr3? {

        let (prefix,_,suffix) = path.splitWild(".")
        if prefix != "" {
            let child = makeChild(prefix)
            if suffix.isEmpty, let head = head {
                child.children = head.children
                child.val = head.val
            }
            else {
                // don't return tail of path chain
                let _ = child.makePath(suffix, head)
            }
            // return nead of path chain
            return child
        }
        return nil
    }

    public func findPath(_ path: String) -> Tr3? {

        if path == "" { return self }

        let (prefix,_,suffix) = path.splitWild(".")

        if name == prefix { return findPath(suffix) }

        for child in children {
            if child.name == prefix { return child.findPath(suffix) }
        }
        return nil
    }
}
