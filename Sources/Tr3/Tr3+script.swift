//
//  Tr3+script.swift
//
//  Created by warren on 4/16/19.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

import Foundation

extension Tr3 {

    /// test for `a.b.c` and not `a {b c}`
    func hasSoloDescendants() -> Bool {
        if children.count > 1 { return false }
        return true
    }

    /// `a { b c }` or `a { b.c d.e }`
    func hasShallowChildren() -> Bool {

        for child in children {
            if !child.hasSoloDescendants() { return false }
        }
        return true
    }
    /// Is this Tr3 elegible to shorten with a dot?
    ///
    ///     shorten `a { z }` to `a.z`,
    ///     but not `a:1 { z }` to a:1.z,
    ///     and not `a<-b { z }` to a<-b.z,
    func canShortenWithDot() -> Bool {
        if val != nil,edgeDefs.edgeDefs.count > 0 {
            return true
        }
        return false 
    }
    public func makeScript(_ i: Int = 0, pretty: Bool = false) -> String {

        var script = name
        script += val?.scriptVal() ?? ""
        script += edgeDefs.makeScript()

        func bracketChildren(_ openBracket:String,_  closeBracket:String) {
            script += openBracket
            for child in children {
                if script.last != "\n", !child.hasSoloDescendants() { script += "\n" }
                script += child.makeScript(i+1, pretty:pretty)
            }
            script += closeBracket
        }
        func soloDotChild() {
            script += "."
            for child in children {
                script += child.makeScript(i+1, pretty:pretty)
            }
        }
        if children.isEmpty {
            return script + " "
        }

        else if pretty {
            if canShortenWithDot() {
                if hasShallowChildren()  { bracketChildren(" { ","} ") }

                else                     { bracketChildren(" {\n","}\n") }
            }
            else if children.count == 1,
                hasSoloDescendants()     { soloDotChild() }

            else if hasShallowChildren() { bracketChildren(" { ","}\n") }

            else                         { bracketChildren(" {\n","}\n") }
        }
        else /* not pretty */            { bracketChildren(" { ","} ") }
        return script
    }

    /// - Parameter session: show instance for session instead of full declaration
    public func dumpScript(_ i: Int = 0, session:Bool = false) -> String {

        let prefix = type == .proto ? ":" : ""
        //var script = prefix + scriptLineage(1) + (val?.dumpVal(session:session) ?? "")
        var script =  name + (val?.dumpVal(session:session) ?? "")

        func dumpTypeEdges(_ edges:[Tr3Edge]) -> String {
            
            if edges.isEmpty { return  ""}
            var script = edges.first?.scriptEdgeFlag() ?? ""
            if edges.count > 1 { script += "(" }
            for edge in edges  {
                if let pathrefs = edge.rightTr3?.pathrefs,
                    pathrefs.count > 0   {
                    if pathrefs.count > 1 { script += "(" }
                    for pathref in pathrefs {
                        script += script.parenSpace() + pathref.scriptLineage(2)
                    }
                    if pathrefs.count > 1 { script+=") " }
                }
                else {
                    script += edge.dumpVal(self, session:session)
                }
            }
            if edges.count > 1 { script.removeLast() ; script += ") " }
            return script
        }

        func dumpTr3Edges() -> Bool {

            if tr3Edges.count > 0 {
                var leftEdges = [Tr3Edge]()
                for edge in tr3Edges.values {
                    if edge.leftTr3 == self {
                        leftEdges.append(edge)
                    }
                }
                if leftEdges.count > 0 {
                    leftEdges.sort { $0.id < $1.id }
                    var edgeFlags = Tr3EdgeFlags()
                    var leftTypeEdges = [Tr3Edge]()
                    for edge in leftEdges {
                        if edge.edgeFlags != edgeFlags {
                            edgeFlags = edge.edgeFlags
                            script += dumpTypeEdges(leftTypeEdges)
                            leftTypeEdges.removeAll()
                        }
                        leftTypeEdges.append(edge)
                    }
                    script += dumpTypeEdges(leftTypeEdges)
                    return true
                }
            }
            return false
        }
        func dumpChildren() {
            if children.count > 0 {
                script += script.parenSpace() + "{"
                for child in children {
                    script += script.parenSpace() + child.dumpScript(i+1,session:session)
                }
                script += script.parenSpace() + "}"
            }
        }
        
        // ────────────── begin ──────────────
        
        if !dumpTr3Edges(), edgeDefs.edgeDefs.count > 0 {
            script += edgeDefs.makeScript()
        }
        dumpChildren()
        return script
    }
    static func dumpTr3s(_ tr3s:[Tr3]) -> String {

        if tr3s.isEmpty { return "" }
        var script = tr3s.count > 1 ? "(" : ""
        for tr3 in tr3s {
            script += script.parenSpace() + tr3.scriptLineage(2)
        }
        script += tr3s.count > 1 ? ")" : ""
        return script
    }
    /// create "a.b.c" from c in `a{b{c}}`, but not √.b.c from b
    public func scriptLineage(_ level:Int) -> String {
        if let parent = parent, parent.name != "√",  level > 0 {
             return parent.scriptLineage(level-1) + "." + name
        }
        else {
            return name
        }
    }

}
