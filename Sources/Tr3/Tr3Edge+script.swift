//  Tr3Edge+script.swift
//
//  Created by warren on 5/18/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

extension Tr3Edge {
    
    public func scriptEdgeFlag(padSpace: Bool = false) -> String {
        var script = Tr3EdgeDef.scriptEdgeFlag(edgeFlags, active)
        if padSpace, script.count > 0 {
            script += " "
        }
        return script
    }
}
