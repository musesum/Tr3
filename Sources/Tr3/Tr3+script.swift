//
//  Tr3+script.swift
//
//  Created by warren on 4/16/19.
//  Copyright © 2019 DeepMuse
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

    /** Is this Tr3 elegible to shorten with a dot?

     shorten `a { z }` to `a.z`,
     but not `a(1) { z }` to a(1).z,
     and not `a<<b { z }` to a<<b.z,
     */
    func canShortenWithDot() -> Bool {
        if val != nil,edgeDefs.edgeDefs.count > 0 {
            return true
        }
        return false 
    }
    
    public func makeScript(_ indent: Int = 0, pretty: Bool = false) -> String {

        var script = name

        func begin() -> String {

            script.plus(val?.scriptVal())

            if children.isEmpty {
                script.plus(getTr3Comment())
            }
            else if pretty {
                if canShortenWithDot() {
                    if hasShallowChildren()  { bracketChildren("{ ","} ") }
                    else                     { bracketChildren("{\n","}\n") }
                }
                else if children.count == 1,
                        hasSoloDescendants() { soloDotChild() }

                else if hasShallowChildren() { bracketChildren("{ ","}\n") }
                else                         { bracketChildren("{\n","}\n") }
            }
            else /* not pretty */            { bracketChildren("{ ","} ") }

            script.plus(edgeDefs.makeScript())
            script.plus(comments.getComments(.edges, index: -1))
            return script
        }

        func bracketChildren(_ openBracket: String,_  closeBracket: String) {
            script.plus(openBracket)
            script.plus(getTr3Comment())
            var index = 0
            for child in children {
                if script.last != "\n", !child.hasSoloDescendants() { script += "\n" }
                script.plus(child.makeScript(indent + 1, pretty: pretty))
                index += 1
                script.plus(comments.getComments(.child, index: index))
            }
            script += closeBracket
        }

        /// print `a.b.c` instead of `a { b { c } } }`
        func soloDotChild() {
            script += "."
            for child in children {
                script += child.makeScript(indent + 1, pretty: pretty)
            }
        }
        return begin() // ────────────────────────────
    }

    func getTr3Comment() -> String {
        var result = ""
        if comments.have(type: .child) {
            result = comments.getComments(.child, index: 0)
            // ToDo: Side effect removes preceeding space
            if result.count > 0, result.first == "," {
                //!! script = script.without(trailing: " ")
            }
        }
        return result
    }
    
    func getCopiedFrom() -> String {
        var result = ""
        for copyTr3 in copied {
            result += "@" + copyTr3.name + " "
        }
        return result
    }

    func getEdgeDefs(_ session: Bool) -> String {
        var result = ""
        if let edges = getTr3Edges(session) {
            result = edges
            result += comments.getComments(.edges, index: -1)
        }
        else if edgeDefs.edgeDefs.count > 0 {
            result += edgeDefs.makeScript()
            result += comments.getComments(.edges, index: -1)
        }
        return result
    }

    func getTypeEdges(_ edges:[Tr3Edge],_ session: Bool) -> String {

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
                script += edge.dumpVal(self, session: session)
            }
        }
        if edges.count > 1 { script.removeLast() ; script += ") " }
        return script
    }

    func getTr3Edges(_ session: Bool) -> String? {

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
                        result += getTypeEdges(leftTypeEdges, session)
                        leftTypeEdges.removeAll()
                    }
                    leftTypeEdges.append(edge)
                }
                result += getTypeEdges(leftTypeEdges, session)
                return result
            }
        }
        return nil
    }
    func getChildren(_ indent: Int,_ session: Bool) -> String {
        var result = ""
        if children.count > 0 {
            result = "{ " + getTr3Comment() + "\n"
            var index = 0 // index indicates how many children already added when comment was added
            for child in children {
                index += 1
                result += result.parenSpace() + child.dumpScript(indent+1, session: session)
            }
            result += result.parenSpace() + "}\n"
        }
        return result
    }

    /** create a parse ready String

     - Parameters
        - indent: depth level in tree deterimines indentation
        - session: show instance for session instead of full declaration
     */
    public func dumpScript(_ indent: Int = 0, session: Bool = false) -> String {

        var script = name

        script.plus(getCopiedFrom())
        script.plus(val?.dumpVal(session: session))
        script.plus(getEdgeDefs(session))
        if children.isEmpty {
            script.plus(getTr3Comment())
        }
        else {
            script.plus(getChildren(indent, session))
        }
        return script
    }
    
    static func dumpTr3s(_ tr3s:[Tr3]) -> String {

        if tr3s.isEmpty { return "" }
        var script = tr3s.count > 1 ? "(" : ""
        for tr3 in tr3s {
            script.plus(tr3.scriptLineage(2))
        }
        script += tr3s.count > 1 ? ")" : ""
        return script
    }
    /// create "a.b.c" from c in `a{b{c}}`, but not √.b.c from b
    public func scriptLineage(_ level: Int) -> String {
        if let parent = parent, parent.name != "√",  level > 0 {
             return parent.scriptLineage(level-1) + "." + name
        }
        else {
            return name
        }
    }

}
