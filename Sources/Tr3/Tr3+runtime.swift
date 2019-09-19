//  Tr3+runtime.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

import QuartzCore
import Par // visitor

extension Tr3 {

    public func setVal(_ any: Any,_ options: Tr3SetOptions,_ visitor:Visitor = Visitor(0)) {

        /// clean up scaffolding from parsing a Ternary,
        /// todo: redo scaffolding instead of overloading val
        if let _ = val as? Tr3ValPath {
            val = nil
        }
        if options.contains(.cache) {
            Tr3Cache.add(self,any,options,visitor)
        }
        // any is a Tr3Val
        else if let fromVal = any as? Tr3Val {
            // no defined value, so activate will pass fromVal onto edge successors
            if passthrough {
                val = fromVal
            }
                // set my val to fromVal, with rescaling
            else if let val = val {
                val.setVal(fromVal)
            }
        }
        // any is not a Tr3Val, so pass onto my Tr3Val if it exists
        else if let val = val {
            val.setVal(any, options)
        }
            // I don't have a Tr3Val yet, so maybe create one for me
        else if options.contains(.create) {
            passthrough = false

            switch any {
            case let v as Int:      val = Tr3ValScalar(with:Float(v))
            case let v as Float:    val = Tr3ValScalar(with:v)
            case let v as CGFloat:  val = Tr3ValScalar(with:Float(v))
            case let v as CGPoint:  val = Tr3ValTuple(with:v)
            case let v as String:   val = Tr3ValQuote(with:v)
            default: print("*** unknown val(\(any))")
            }
        }
        // maybe pass along my Tr3Val to other Tr3Nodes and closures
        if options.contains(.activate) {
            activate(visitor)
        }
    }

    /// pass along
    public func activate(_ visitor: Visitor = Visitor(0)) { //func bang() + func allEvents(_ event: Tr3Event) {

        if visitor.newVisit(id) {
            for closure in closures {
                closure(self,visitor)
            }
            for tr3Edge in tr3Edges.values {
                if tr3Edge.active {
                    tr3Edge.followEdge(self, visitor)
                }
            }
        }
    }


    func findEdgeTern(_ edge:Tr3Edge) -> Tr3ValTern? {
        for edgeDef in edgeDefs.edgeDefs {
            if edgeDef.edges.contains(where: { $0.key == edge.key }) {
                return edgeDef.ternVal
            }
        }
        return nil
    }

    /// Some nodes have no value of its own, acting as a switch
    /// to merely point to the the value, as it moves through.
    /// If the node has a value of its own, then remap
    /// its value and the range of the incoming value.
    ///
    func setEdgeVal(_ fromVal: Tr3Val?,_ visitor: Visitor) {
        
        if visitor.visited.contains(id) {
            return // already have visited left tr3
        }
        if let fromVal = fromVal {

            if val == nil {
                passthrough = true  // no defined value so pass though
            }
            if passthrough {
                val = fromVal // hold passthrough value,for successors to rescale
            }
            else if let val = val {
                val.setVal(fromVal)  // otherwise scale value now
            }
        }
    }
}
