//  Tr3Parse+log.swift
//
//  Created by warren on 4/12/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par

extension Tr3Parse {

    func log(_ t: Tr3?, _ parItem: ParItem, _ i: Int) {

        let tr3Name = t?.name ?? "nil"
        let pattern = parItem.node?.pattern ?? "nil"
        let nodeId = ""//.\(parItem.node!.id)"
        let nodeVal = parItem.value?.without(trailing: " ") ?? ""
        let prePad = " ".padding(toLength: i, withPad: " ", startingAt: 0)
        let nodePad = prePad + ("(" + tr3Name + "," + pattern + nodeId + nodeVal + ")" )
        let nodeCall = nodePad.padding(toLength: 24, withPad: " ", startingAt: 0)
        
        // show array of next items
        var nextArray = " ["
        var arrayOp = ""
        for nextPar in parItem.nextPars {
            if let pattern = nextPar.node?.pattern, pattern != "" {
                nextArray += arrayOp + pattern
                arrayOp = ", "
            }
            else if let value = nextPar.value {
                nextArray += arrayOp + value
                arrayOp = ", "
            }
        }
        nextArray += "]"

        print (nodeCall + nextArray)
    }


}
