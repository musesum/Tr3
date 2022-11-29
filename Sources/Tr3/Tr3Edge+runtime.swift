//
//  Tr3Edge+runtime.swift
//
//  Created by warren on 5/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par // visitor

extension Tr3Edge {
    
    func followEdge(_ fromTr3: Tr3,
                    _ visitor: Visitor) {

        let leftToRight = fromTr3 == leftTr3 // a >> b
        let rightToLeft = !leftToRight       // a << b
        let destTr3 = leftToRight ? rightTr3 : leftTr3

        if edgeFlags.contains(.ternIf) {

            if leftToRight, let ternVal = rightTr3.findEdgeTern(self) {

                ternVal.recalc(leftTr3, rightTr3, .activate , visitor)
                rightTr3.activate(visitor)
                //print("\(fromTr3.name)◇→\(destTr3?.name ?? "")")
            }
            else if rightToLeft, let ternVal = leftTr3.findEdgeTern(self) {

                ternVal.recalc(rightTr3, leftTr3, .activate, visitor)
                leftTr3.activate(visitor)
                //print("\(fromTr3.name)◇→\(destTr3?.name ?? "")")
            }
        }
        else {

            if  leftToRight && edgeFlags.contains(.output) ||
                rightToLeft && edgeFlags.contains(.input) {

                let val = assignNameVals()
                if  destTr3.setEdgeVal(val, visitor) {
                    destTr3.activate(visitor)
                } else {
                    /// Did not meet conditionals, so stop.
                    /// for example, when cc != 13 for
                    /// `repeatX(cc == 13, val 0…127, chan, time)`
                }
            }
        }

        /// apply fromTr3 values to edge expressions
        /// such as applyihg `b(v 1)` to `a(x:v),`
        /// for `a(x,y), b(v 0) >> a(x:v)`
        func assignNameVals() -> Tr3Val? {

            if let defVal {

                if let defExprs = defVal as? Tr3Exprs,
                   let frExprs = fromTr3.val as? Tr3Exprs {

                    for (name,val) in defExprs.nameAny {
                        if (val as? String) == "" {
                            if let frVal = frExprs.nameAny[name] {
                                defExprs.nameAny[name] = frVal
                            }
                        }
                    }
                }
                return defVal
            }
            return fromTr3.val
        }
    }
}

