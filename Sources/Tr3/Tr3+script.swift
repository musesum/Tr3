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
    
    public func script(compact: Bool) -> String {

        func scriptChildren() {
            //?? print(name+"ⁿ" ,terminator: "")
            script.spacePlus("{")
            script.spacePlus(comments.getComments(.child))
            if (script.last != "\n") && (script.last != ",") {
                script.spacePlus("\n")
            }
            for child in children {
                script.spacePlus(child.script(compact: compact))
                if (script.last != "\n") && (script.last != ",") {
                    script.spacePlus("\n")
                }
            }
            script.spacePlus("}\n")
        }
        /// print `a.b.c` instead of `a { b { c } } }`
        func scriptOnlyChild() {
            //?? print(name+"¹" ,terminator: "")
            script += "."
            for child in children {
                script += child.script(compact: compact)
            }
        }

        // begin --------------------------------------------
        //?? print(name+"⁰" ,terminator: "")
        var script = name
        script.spacePlus(val?.scriptVal())

        if compact {
            switch children.count {
                    case 0: script.spacePlus(comments.getComments(.child))
                    case 1: scriptOnlyChild()
                    default: scriptChildren()
            }
        } else { // not pretty
            switch children.count {
                case 0: script.spacePlus(comments.getComments(.child))
                default: scriptChildren()
            }
        }
        script.spacePlus(edgeDefs.dumpScript(self))
        script.spacePlus(comments.getComments(.edges))
        return script
    }


    func getCopiedFrom() -> String {
        var result = ""
        var delim = ": "
        for copyTr3 in copied {
            result += delim + copyTr3.name
            delim = ", "
        }
        if result.count > 0 {
            result += " "
        }
        return result
    }

    private func dumpEdgeDefs(_ session: Bool) -> String {
        var script = ""
        if let edgesScript = dumpTr3Edges(session) {
            script = edgesScript
            if tr3Edges.count == 1 {
                script += comments.getComments(.edges)
            }
        }
        else if edgeDefs.edgeDefs.count > 0 {
            script += edgeDefs.dumpScript(self)
            script += comments.getComments(.edges)
        }
        return script
    }

    private func dumpPathRefs(_ edge: Tr3Edge) -> String {

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
    func dumpTypeEdges(_ edges: [Tr3Edge], _ session: Bool) -> String {

        if edges.isEmpty { return  "" }
        guard let firstEdge = edges.first else { return "" }
        var script = firstEdge.scriptEdgeFlag(padSpace: true)
        if edges.count > 1 { script += "(" }
        var delim = ""
        for edge in edges  {
        
            let pathScript = dumpPathRefs(edge)
            if pathScript.count > 0 {
                script += delim + pathScript
            }
            else {
                script += delim + edge.dumpEdgeVal(self, session: session)
                delim = comments.getEdgesDelim()
            }
        }
        if edges.count > 1 { script += ")" }
        return script
    }

    private func dumpTr3Edges(_ session: Bool) -> String? {

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
                        result += dumpTypeEdges(leftTypeEdges, session)
                        leftTypeEdges.removeAll()
                    }
                    leftTypeEdges.append(edge)
                }
                result += dumpTypeEdges(leftTypeEdges, session)
                return result
            }
        }
        return nil
    }
    func getChildren(_ session: Bool) -> String {
        var result = ""
        if children.count > 0 {
            let comment = comments.getComments(.child)
            if comment == "," {
                result = "{ " + comment.with(trailing: " ")
            } else {
                result = "{ " + comment + "\n"
            }
            var index = 0 // index indicates how many children already added when comment was added
            for child in children {
                index += 1
                result += result.parenSpace() + child.dumpScript(session: session)
            }
            result += result.parenSpace() + "}\n"
        }
        return result
    }

    /** create a parse ready String

     - Parameters
        - session: show instance for session instead of full declaration
     */
    public func dumpScript(session: Bool = false) -> String {

        var script = name
        script.spacePlus(getCopiedFrom())
        let dumpVal = val?.dumpVal(session: session)
        script.spacePlus(dumpVal)
        script.spacePlus(dumpEdgeDefs(session))
        if children.isEmpty {
            let comments = comments.getComments(.child)
            script.spacePlus(comments)
            if dumpVal != nil, comments.isEmpty {
                script += "\n"
            }
        }
        else {
            script.spacePlus(getChildren(session))
        }
        return script
    }
    
    static func dumpTr3s(_ tr3s: [Tr3]) -> String {

        if tr3s.isEmpty { return "" }
        var script = tr3s.count > 1 ? "(" : ""
        for tr3 in tr3s {
            script.spacePlus(tr3.scriptLineage(2))
        }
        script += tr3s.count > 1 ? ")" : ""
        return script
    }

    /// create "a.b.c" from c in `a{b{c}}`, but not √.b.c from b
    public func scriptLineage(_ level: Int) -> String {
        if let parent = parent, parent.name != "√", level > 0  {
             return parent.scriptLineage(level-1) + "." + name
        }
        else {
            return name
        }
    }

}
