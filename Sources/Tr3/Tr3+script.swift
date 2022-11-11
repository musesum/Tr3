//
//  Tr3+script.swift
//
//  Created by warren on 4/16/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation


extension Tr3 {
    
    /** Is this Tr3 elegible to shorten with a dot?
     
     shorten `a { z }` to `a.z`,
     but not `a(1) { z }` to a(1).z,
     and not `a<<b { z }` to a<<b.z,
     */
    private func canShortenWithDot() -> Bool {
        if val != nil, edgeDefs.edgeDefs.count > 0 {
            return true
        }
        return false
    }

    public func script(_ scriptFlags: Tr3ScriptFlags) -> String {
        
        var script = name
        script.spacePlus(val?.scriptVal())
        
        if scriptFlags.contains(.compact) {
            switch children.count {
                case 0: script.spacePlus(comments.getComments(.child, scriptFlags))
                case 1: scriptAddOnlyChild()
                default: scriptAddChildren()
            }
        } else { // not pretty
            switch children.count {
                case 0: script.spacePlus(comments.getComments(.child, scriptFlags))
                default: scriptAddChildren()
            }
        }
        script += edgeDefs.scriptVal(scriptFlags)
        script += comments.getComments(.edges, scriptFlags)
        return script
        
        func scriptAddChildren() {
            script.spacePlus("{")
            script.spacePlus(comments.getComments(.child, scriptFlags))
            if (script.last != "\n"),
               (script.last != ",") {
                
                script += "\n"
            }
            for child in children {
                script.spacePlus(child.script(scriptFlags))
                if (script.last != "\n"),
                   (script.last != ",") {
                    
                    script += "\n"
                }
            }
            script.spacePlus("}\n")
        }
        /// print `a.b.c` instead of `a { b { c } } }`
        func scriptAddOnlyChild() {
            script += "."
            for child in children {
                script += child.script(scriptFlags)
            }
        }
    }
    
    func getCopiedFrom() -> String {
        var result = ""
        var delim = "@"
        for copyTr3 in copied {
            result += delim + copyTr3.name
            delim = ", "
        }
        if result.count > 0 {
            result += " "
        }
        return result
    }
    
    private func scriptEdgeDefs(_ scriptFlags: Tr3ScriptFlags) -> String {
        var script = ""
        if let edgesScript = scriptTr3Edges(scriptFlags) {
            script = edgesScript
            if tr3Edges.count == 1 {
                script += comments.getComments(.edges, scriptFlags)
            }
        }
        else if edgeDefs.edgeDefs.count > 0 {
            script += edgeDefs.scriptVal(scriptFlags)
            script += comments.getComments(.edges, scriptFlags)
        }
        return script
    }
    
    private func scriptPathRefs(_ edge: Tr3Edge) -> String {
        if let pathrefs = edge.rightTr3.pathrefs, pathrefs.count > 0  {
            var script = pathrefs.count > 1 ? "(" : ""
            var delim = ""
            
            for pathref in pathrefs {
                script += delim + pathref.scriptLineage(2)
                delim = comments.getEdgesDelim()
            }
            if pathrefs.count > 1 { script += ") " }
            return script
        }
        return ""
    }
    
    func scriptTypeEdges(_ edges: [Tr3Edge], _ scriptEdgeFlags: Tr3ScriptFlags) -> String {

        guard let firstEdge = edges.first else { return "" }
        var script = firstEdge.edgeFlags.script(active: firstEdge.active)
        if edges.count > 1 { script += "(" }
        var delim = ""
        for edge in edges  {
            
            let pathScript = scriptPathRefs(edge)
            if pathScript.count > 0 {
                script += delim + pathScript
            }
            else {
                script += delim + edge.scriptEdgeVal(self, scriptEdgeFlags)
                delim = comments.getEdgesDelim()
            }
        }
        if edges.count > 1 { script += ")" }
        return script
    }
    
    private func scriptTr3Edges(_ scriptFlags: Tr3ScriptFlags) -> String? {
        
        if tr3Edges.count > 0 {
            
            var leftEdges = [Tr3Edge]()
            for edge in tr3Edges.values {
                if edge.leftTr3 == self {
                    leftEdges.append(edge)
                }
            }
            if leftEdges.count > 0 {
                
                leftEdges.sort { $0.id < $1.id }
                var result = ""
                var edgeFlags = Tr3EdgeFlags()
                var leftTypeEdges = [Tr3Edge]()
                for edge in leftEdges {
                    if edge.edgeFlags != edgeFlags {
                        
                        edgeFlags = edge.edgeFlags
                        result += scriptTypeEdges(leftTypeEdges, scriptFlags)
                        leftTypeEdges.removeAll()
                    }
                    leftTypeEdges.append(edge)
                }
                result += scriptTypeEdges(leftTypeEdges, scriptFlags)
                return result
            }
        }
        return nil
    }


    func scriptChildren(_ scriptFlags: Tr3ScriptFlags) -> String {
        var script = ""
        if showChildren(scriptFlags) {
            let comment = comments.getComments(.child, scriptFlags)
            if comment == "," {
                // { a, b}
                script = "{ " + comment.with(trailing: " ")
            } else {
                script = "{ " + comment
            }
            
            for child in children {
                script.spacePlus(child.scriptTr3(scriptFlags))
            }
            script.spacePlus("}\n")
        }
        return script
    }

    func showChildren(_ scriptFlags: Tr3ScriptFlags) -> Bool {
        if scriptFlags.contains(.delta) {
            if changes == 0 { return false }
            for child in children {
                if child.changes > 0 { return true }
            }
            return false
        }
        return children.count > 0
    }
    public func scriptCompactRoot(_ scriptFlags: Tr3ScriptFlags) -> String {
        var script = ""
        for child in children {
            script += child.script(scriptFlags)
        }
        return script
    }

    /// Populate tree hierarchy of total changes made to each subtree.
    /// When using Tr3ScriptFlag .delta, no changes to subtree are printed out
    func countDeltas() -> UInt {
        if let val, val.hasDelta() {
            changes += 1
        }
        for child in children {
            changes += child.countDeltas()
        }
        return changes
    }
    public func scriptRoot(_ scriptFlags: Tr3ScriptFlags = []) -> String {
        var script = ""
        if scriptFlags.contains(.delta) {
            countDeltas()
            for child in children {
                if child.changes > 0 {
                    let childScript = child.scriptTr3(scriptFlags)
                    script.spacePlus(childScript)
                }
            }
        } else {

            for child in children {
                let childScript = child.scriptTr3(scriptFlags)
                script.spacePlus(childScript)
            }
        }

        return script
    }
    
    /// create a parse ready String
    ///
    public func scriptTr3(_ scriptFlags: Tr3ScriptFlags) -> String {

        if scriptFlags.contains(.delta) && changes == 0 { return "" }

        var script = name
        if scriptFlags.contains(.copyAt) {
            script.spacePlus(getCopiedFrom())
        }
        let scriptVal = val?.scriptVal(scriptFlags) ?? ""
        script += scriptVal
        if scriptFlags.contains(.edge) {
            script += scriptEdgeDefs(scriptFlags)
        }
        if children.isEmpty {
            
            let comments = comments.getComments(.child, scriptFlags)
            script.spacePlus(comments)
            if scriptVal.count > 0,
               comments.count == 0 {
                script += "\n"
            }
        }
        else {
            script.spacePlus(scriptChildren(scriptFlags))
        }
        return script
    }
    
    
    static func scriptTr3s(_ tr3s: [Tr3]) -> String {
        
        if tr3s.isEmpty { return "" }
        var script = tr3s.count > 1 ? "(" : ""
        for tr3 in tr3s {
            script.spacePlus(tr3.scriptLineage(2))
        }
        script += tr3s.count > 1 ? ")" : ""
        return script
    }
    
    /// create "a.b.c" from c in `a{b{c}}`, but not √.b.c from b
    public func scriptLineage(_ level: Int = 999) -> String {
        if let parent = parent, parent.name != "√", level > 0  {
            return parent.scriptLineage(level-1) + "." + name
        }
        else {
            return name
        }
    }
    
}
