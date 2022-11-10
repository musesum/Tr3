//  Tr3ValTern+script.swift
//
//  Created by warren on 6/3/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

extension Tr3ValTern {

    func scriptRadioPrev(start: Bool = false) -> String {

        var script = radioPrev?.scriptRadioPrev() ?? "("
        if start {
            script += "* "
        } else {
            let lineage = pathTr3s.first?.scriptLineage(1) ?? " ??"
            script += "\(lineage):\(id) "
        }
        return script
    }
    
    func scriptRadioNext() -> String {
        let lineage = pathTr3s.first?.scriptLineage(1) ?? " ??"
        var script = "\(lineage):\(id) "
        script += radioNext?.scriptRadioNext() ?? ")"
        return script
    }

    func scriptRadio() -> String {
        var script = scriptRadioPrev(start: true)
        script += scriptRadioNext()
        return script
    }
}
