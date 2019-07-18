//
//  Tr3+runtime.swift
//  Par iOS
//
//  Created by warren on 4/4/19.
//

import Foundation
import Par // visitor

extension Tr3 {

    func setVal(_ any: Any?,_ setOp: Tr3SetOptions) {

        /// clean up scaffolding from parsing a Ternary, redo scaffolding later
        if let _ = val as? Tr3ValPath {
            val = nil
        }
        if let val = val {
            val.setVal(any)
        }
        else if setOp.contains(.create) {
            passthrough = false
            if let any = any {
                switch any {
                case let v as Int:      val = Tr3ValScalar(with:Float(v))
                case let v as Float:    val = Tr3ValScalar(with:v)
                case let v as CGFloat:  val = Tr3ValScalar(with:Float(v))
                case let v as CGPoint:  val = Tr3ValTuple(with:v)
                case let v as String:   val = Tr3ValQuote(with:v)
                default: print("*** unknown val(\(any))")
                }
            }
        }
        if setOp.contains(.activate) {
            activate()
        }
    }

    func activate(_ visitor: Visitor = Visitor(0)) { //func bang() + func allEvents(_ event: Tr3Event) {

        if visitor.newVisit(id) {
            for callback in callbacks {
                callback(self,visitor)
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

    /// Some nodes have no value of its own, acting as a switch
    /// to merely point to the the value, as it moves through.
    /// If the node has a value, then remap between scalar ranges.
    ///
    func setEdgeVal(_ fromVal: Tr3Val?,_ visitor: Visitor) {
        
        // already have visited left tr3
        if visitor.visited.contains(id) { return }
        
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
