//
//  Tr3Edge+script.swift
//  Par iOS
//
//  Created by warren on 5/18/19.
//

import Foundation

extension Tr3Edge {
    
    public func scriptEdgeFlag() -> String {
        let script = Tr3EdgeDef.scriptEdgeFlag(edgeFlags,active)
        return script
    }
}
