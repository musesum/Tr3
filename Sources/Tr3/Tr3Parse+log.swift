//
//  Tr3Parse+script.swift
//  Par iOS
//
//  Created by warren on 4/12/19.
//

import Foundation
import Par

extension Tr3Parse {


    func log(_ t:Tr3?, _ parAny:ParAny,_ i:Int) {

        let tr3Name = t?.name ?? "nil"
        let pattern = parAny.node?.pattern ?? "nil"
        let nodeId = ""//.\(parAny.node!.id)"
        let nodeVal = parAny.value != nil ? ":" + parAny.value! : ""
        let prePad = " ".padding(toLength: i, withPad: " ", startingAt: 0)
        let nodePad = prePad + ("(" + tr3Name + "," + pattern + nodeId + nodeVal + ")" )
        let nodeCall = nodePad.padding(toLength: 24, withPad: " ", startingAt: 0)

        // show array of next items
        var nextArray = " ["
        var arrayOp = ""
        for nexti in parAny.next {
            if let pattern = nexti.node?.pattern, pattern != "" {
                nextArray += arrayOp + pattern
                arrayOp = ", "
            }
            else if let value = nexti.value {
                nextArray += arrayOp + value
                arrayOp = ", "
            }
        }
        nextArray += "]"

        print (nodeCall + nextArray)
    }


}
