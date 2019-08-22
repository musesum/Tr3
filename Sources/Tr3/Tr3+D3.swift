//
//  Tr3+D3.swift
//  Tr3Graph
//
//  Created by warren on 6/22/19.
//  Copyright © 2019 Muse. All rights reserved.
//

import Foundation
extension Tr3Edge {

    func makeD3Edge(_ separator: String) -> String {

        if  let leftId = leftTr3?.id,
            let rightId = rightTr3?.id {
            let arrow = scriptEdgeFlag()
            return separator + "'\(leftId)\(arrow)\(rightId)'"
        }
        else {
            return ""
        }
    }
}
extension Tr3 {

    func makeD3Node() -> String {
        
        var script = "\t\t{'id':\(id), 'name':'\(name)'"
        if children.count > 0 {
            script += ", 'children':["
            var sep = ""
            for child in children {
                script += sep + "\(child.id)"
                sep = ","
            }
            script += "]"
        }
        if tr3Edges.count > 0 {
            var leftEdgeCount = 0
            for edge in tr3Edges.values {
                if edge.leftTr3?.id == id {
                    leftEdgeCount += 1
                }
            }
            if leftEdgeCount > 0 {
                script += ", 'edges':["
                var sep = ""
                for edge in tr3Edges.values {
                    if edge.leftTr3?.id == id {
                        script += edge.makeD3Edge(sep)
                        sep = ","
                    }
                }
                script += "]"
            }
        }
        script += "},\n";
        if children.count > 0 {

            for child in children {
                script += child.makeD3Node()
            }
        }
        return script
    }

    func makeD3ChildEdges() -> String {

        var script = ""

        for child in children {
            script += "{'id':'\(id).\(child.id)', 'source':\(id), 'target':\(child.id), 'type':'.'},\n"
        }
        for child in children {
            script += child.makeD3ChildEdges()
        }
        return script
    }

    func makeD3EdgeEdges() -> String {

        var script = ""

        for edge in tr3Edges.values {

            if  let leftId = edge.leftTr3?.id,
                let rightId = edge.rightTr3?.id,
                leftId == id {

                let type = edge.scriptEdgeFlag()
                script += "{'id':'\(leftId)\(type)\(rightId)', 'source':\(leftId), 'target':\(rightId), 'type':'\(type)'},\n"
            }
        }
        for child in children {
            script += child.makeD3EdgeEdges()
        }
        return script
    }

    func makeD3Script() -> String  {

        var script = "var graph = {\n\t'nodes': [\n"
        script += makeD3Node()
        script += "\t],\n\t'links': [\n"
        script += makeD3ChildEdges()
        script += makeD3EdgeEdges()
        script += "\t]\n}"
        return script
    }
}

