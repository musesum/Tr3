//
//  Tr3Edge+runtime.swift
//  Par iOS
//
//  Created by warren on 5/10/19.
//

import Foundation
import Par // visitor

extension Tr3Edge {
    
    func followEdge(_ prevTr3:Tr3,
                    _ visitor: Visitor) {

        let leftToRight = prevTr3 == leftTr3
        let nextTr3 = leftToRight ? rightTr3 : leftTr3

        if edgeFlags.contains(.ternary) {

            if leftToRight,
                let ternVal = rightTr3?.findEdgeTern(self) {

                ternVal.recalc(leftTr3!, rightTr3!, .activate , visitor)
                rightTr3?.activate(visitor)
                //print("\(prevTr3.name)╌>\(nextTr3?.name ?? "")")
            }
            else if !leftToRight,
                let ternVal = leftTr3?.findEdgeTern(self) {

                ternVal.recalc(rightTr3!, leftTr3!, .activate, visitor)
                leftTr3?.activate(visitor)
                //print("\(prevTr3.name)╌>\(nextTr3?.name ?? "")")
            }
        }
        else if let nextTr3 = nextTr3 {

            nextTr3.setEdgeVal(prevTr3.val, visitor)
            nextTr3.activate(visitor)
        }
    }

}
