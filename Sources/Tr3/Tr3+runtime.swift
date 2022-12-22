//  Tr3+runtime.swift
//
//  Created by warren on 4/4/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import QuartzCore
import Par // visitor

extension Tr3 {

    /// combine several expressions into one transaction and activate the callbacks only once
    public func setAnys(_ anys: [Any],
                        _ options: Tr3SetOptions,
                        _ visitor: Visitor) {

        // defer activation until after setting value
        let noActivate = options.subtracting(.activate)

        // set all the expressions
        for any in anys {
            setAny(any, noActivate, visitor)
        }
        // do the deferred activations, if there was one
        if options.contains(.activate) {
            activate(visitor)
        }
    }
    public func setAny(_ any: Any,
                       _ options: Tr3SetOptions,
                       _ visitor: Visitor) { 

        /// clean up scaffolding from parsing a Ternary,
        /// todo: scaffolding instead of overloading val
        if val is Tr3ValPath {
            val = nil
        }
        if options.contains(.cache) {
            Tr3Cache.add(self, any, options, visitor)
        }
        // any is a Tr3Val
        else if let fromVal = any as? Tr3Val {

            if passthrough {
                // no defined value, so activate will pass fromVal onto edge successors
                val = fromVal
            } else if let val {
                // set my val to fromVal, with rescaling
                if val.setVal(fromVal) == false {
                    // condition failed, so avoid activatating edges, below
                    return
                }
            }
        } else if let val {
            // any is not a Tr3Val, so pass onto my Tr3Val if it exists
            if val.setVal(any, options) == false {
                // condition failed, so avoid activatating edges, below
                return
            }
        } else {
            // I don't have a Tr3Val yet, so maybe create one for me
            passthrough = false

            switch any {
            case let v as Int:                val = Tr3ValScalar(self, num: Double(v))
            case let v as Double:             val = Tr3ValScalar(self, num: v)
            case let v as CGFloat:            val = Tr3ValScalar(self, num: Double(v))
            case let v as CGPoint:            val = Tr3Exprs(self, point: v)
            case let v as [(String, Double)]: val = Tr3Exprs(self, nameNums: v)
            default: print("🚫 unknown val(\(any))")
            }
        }
        // maybe pass along my Tr3Val to other Tr3Nodes and closures
        if options.contains(.activate) {
            activate(visitor)
        }
    }

    public func activate(_ visitor: Visitor = Visitor(0)) {

        if visitor.newVisit(id) {
            for closure in closures {
                closure(self, visitor)
            }
            for tr3Edge in tr3Edges.values {
                if tr3Edge.active {
                    tr3Edge.followEdge(self, visitor)
                }
            }
        }
    }

    func findEdgeTern(_ edge: Tr3Edge) -> Tr3ValTern? {
        for edgeDef in edgeDefs.edgeDefs {
            if edgeDef.edges.keys.contains(edge.edgeKey) {
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
    func setEdgeVal(_ fromVal: Tr3Val?,
                    _ visitor: Visitor) -> Bool {
        
        if visitor.visited.contains(id) {
            return false // already have visited left tr3
        }
        if let fromVal {

            if val == nil {
                passthrough = true  // no defined value so pass though
            }
            if passthrough {
                val = fromVal // hold passthrough value, for successors to rescale
            }
            else if let val {
                switch val {

                    case let v as Tr3Exprs:

                        if let fr = fromVal as? Tr3Exprs {
                            return v.setVal(fr)
                        }
                    case let v as Tr3ValScalar:

                        if let fr = fromVal as? Tr3ValScalar {
                            return v.setVal(fr)
                        }
                        else if let frExprs = fromVal as? Tr3Exprs,
                                let lastExpr = frExprs.nameAny.values.first,
                                let fr = lastExpr as? Tr3ValScalar {

                            return v.setVal(fr)
                        }
                    case let v as Tr3ValData:
                        if let fr = fromVal as? Tr3ValData {
                           return v.setVal(fr)
                        }
                    default: break
                }
            }
        }
        return true
    }
}
