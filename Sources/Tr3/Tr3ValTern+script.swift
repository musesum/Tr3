//  Tr3ValTern+script.swift
//
//  Created by warren on 6/3/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation

extension Tr3ValTern {

   override func printVal() -> String {
        return "??"
    }

    override func scriptVal(parens: Bool = true,
                   session: Bool = false,
                   expand: Bool = false) -> String  {

        var script = parens ? "(" : ""
        if expand {
            script += Tr3.scriptTr3s(pathTr3s)
            script += compareOp.isEmpty ? "" : " " + compareOp + " "
            script += Tr3.scriptTr3s(compareRight?.pathTr3s ?? [])
        } else {
            script += path
            script += compareOp.isEmpty ? "" : " " + compareOp + " "
            script += compareRight?.path ?? ""
        }
        if let thenVal = thenVal {

            script.spacePlus("?")
            script.spacePlus(thenVal.scriptVal(parens: false))
        }
        if let elseVal = elseVal {

            script.spacePlus(":")
            script.spacePlus(elseVal.scriptVal(parens: false))
        }
        if let radioNext = radioNext {

            script.spacePlus("|")
            script.spacePlus(radioNext.scriptVal(parens: false))
        }
        script += parens ? ")" : ""
        return script.with(trailing: " ")
    }
}
extension Tr3ValTern {

    func scriptRadioPrev(start: Bool = false) -> String {
        var script = radioPrev?.scriptRadioPrev() ?? "("
        if start {
            script += "* "
        }
        else {
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
