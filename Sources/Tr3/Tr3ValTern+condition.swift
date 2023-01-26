//  Tr3TernIf.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

extension Tr3ValTern {

    func testCondition(_ prevTr3: Tr3,
                       _ act: Tr3Act) -> Bool {

        // a in `a b w <- (a ? 1: b ? 2)`
        if compareOp == "" {
            
            if let pathTr3 = pathTr3s.last {

                if let scalarVal = pathTr3.val as? Tr3ValScalar {
                    return scalarVal.now > 0
                }
                if act == .sneak { return false }
                return pathTr3.id == prevTr3.id
            }
        }
        else if pathTr3s.count > 0,
            let rightVal = compareRight?.tr3.val {

            for pathTr3 in pathTr3s {
                if let pathVal = pathTr3.val {
                    if bothMatchFlags(pathVal, rightVal, [.now])  {

                        switch compareOp {
                        case "==": return pathVal == rightVal
                        case ">=": return pathVal >= rightVal
                        case ">" : return pathVal >  rightVal
                        case "<=": return pathVal <= rightVal
                        case "<" : return pathVal <  rightVal
                        case "!=": return pathVal != rightVal
                        default: break
                        }
                    }
                }
            }
        }
        return false

        // check if both match and are scalars or quotes
        func bothMatchFlags(_ left: Tr3Val,
                            _ right: Tr3Val,
                            _ matchFlags: [Tr3ValFlags]) -> Bool {
            
            for matchFlag in matchFlags {
                if  left.valFlags.contains(matchFlag),
                    right.valFlags.contains(matchFlag) {
                    return true
                }
            }
            return false
        }

    }

}
