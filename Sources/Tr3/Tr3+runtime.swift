//
//  Tr3+runtime.swift
//  Par iOS
//
//  Created by warren on 4/4/19.
//

import Foundation
import Par // visitor

extension Tr3 {

    func setVal(_ num_: Float,_ setOp: Tr3SetOptions) {

        if let val = val as? Tr3ValScalar {
            val.setFloat(num_)
            if setOp.contains(.activate) {
                activate()
            }
        }
        else if setOp.contains(.create) {
            val = Tr3ValScalar(with: num_)
            passthrough = false
            if setOp.contains(.activate) {
                activate()
            }
        }
        else {
            print("*** mismatched setVal(\(num_)) for val:\(val?.printVal() ?? "nil")")
        }
    }

    func activate(_ visitor: Visitor = Visitor(0)) { //func bang() + func allEvents(_ event: Tr3Event) {

        if visitor.newVisit(id) {
            for callback in callbacks {
                callback(val)
            }
            for tr3Edge in tr3Edges {
                if tr3Edge.active {
                    tr3Edge.followEdge(self, visitor)
                }
            }
        }
    }

    func findEdgeTern(_ edge:Tr3Edge) -> Tr3ValTern? {
        for edgeDef in edgeDefs.edgeDefs {
            if edgeDef.edges.contains(where: {$0.id == edge.id }) {
                return edgeDef.defVal as? Tr3ValTern ?? nil
            }
        }
        return nil
    }

    /**
     Some nodes have no value of its own, acting as a switch
     to merely point to the the value, as it moves through.
     If the node has a value, then remap between scalar ranges.
     */
    func setEdgeVal(_ fromVal: Tr3Val?,_ visitor: Visitor) {
        
        // already have visited left tr3
        if visitor.visited.contains(id) {  return }
        
        if let fromVal = fromVal {
            
            // no value so pass though values from right edge
            if val == nil {
                passthrough = true
            }
            // passing through, value may still rescale successive edge
            if passthrough {
                val = fromVal;
            }
                // remap value
            else if let val = val {
                
                val.setVal(fromVal)
            }
        }
    }
}
