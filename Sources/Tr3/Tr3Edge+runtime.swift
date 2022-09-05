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

        let leftToRight = fromTr3 == leftTr3
        let destTr3 = leftToRight ? rightTr3 : leftTr3

        if edgeFlags.contains(.ternIf) {

            if leftToRight, let ternVal = rightTr3.findEdgeTern(self) {

                ternVal.recalc(leftTr3, rightTr3, .activate , visitor)
                rightTr3.activate(visitor)
                //print("\(fromTr3.name)◇→\(destTr3?.name ?? "")")
            }
            else if !leftToRight, let ternVal = leftTr3.findEdgeTern(self) {

                ternVal.recalc(rightTr3, leftTr3, .activate, visitor)
                leftTr3.activate(visitor)
                //print("\(fromTr3.name)◇→\(destTr3?.name ?? "")")
            }
        }
        else {

            if   leftToRight && edgeFlags.contains(.output) ||
                !leftToRight && edgeFlags.contains(.input) {

                let val = defVal ?? fromTr3.val
                destTr3.setEdgeVal(val, visitor)
                destTr3.activate(visitor)
            }
        }
    }
}

