//  Tr3Edge+script.swift
//
//  Created by warren on 5/18/19.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

import Foundation

extension Tr3Edge {
    
    public func scriptEdgeFlag() -> String {
        let script = Tr3EdgeDef.scriptEdgeFlag(edgeFlags,active)
        return script
    }
}
