//  Tr3Edge+script.swift
//
//  Created by warren on 5/18/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

extension Tr3Edge {
    
    func scriptEdgeVal(_ tr3: Tr3, session: Bool = false) -> String {

        var script = ""

        if leftTr3 == tr3 {
            script += rightTr3.scriptLineage(Tr3Edge.LineageDepth)
        }
        else if rightTr3 == tr3 {
            script += leftTr3.scriptLineage(Tr3Edge.LineageDepth)
        }
        script += defVal?.scriptVal(session: session) ?? ""
        return script
    }

}
