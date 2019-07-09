//
//  Tr3EdgeDefs.swift
//  Par iOS
//
//  Created by warren on 4/28/19.
//

import Foundation

public class Tr3EdgeDefs {

    var edgeDefs = [Tr3EdgeDef]()

    init () {
    }
    convenience init(with: Tr3EdgeDefs) {
        self.init()
        for edgeDef in with.edgeDefs {
            edgeDefs.append(edgeDef.copy())
        }
    }
    func copy() -> Tr3EdgeDefs {
        return Tr3EdgeDefs(with: self)
    }
    
    public func addEdgeDef(_ edgeOp:String?) {

        if let edgeOp = edgeOp {

            let edgeFlags = Tr3EdgeFlags(with:edgeOp)
            let edgeDef = Tr3EdgeDef(flags: edgeFlags)
            edgeDefs.append(edgeDef)
        }
    }
    /// parsing always decorates the last current Tr3EdgeDef
    /// if there isn't a last Tr3EdgeDef, then make one
    public func lastEdgeDef() -> Tr3EdgeDef {
        if edgeDefs.isEmpty {
            let edgeDef = Tr3EdgeDef()
            edgeDefs.append(edgeDef)
            return edgeDef
        }
        else {
            return edgeDefs.last!
        }
    }

 
    func makeScript(_ i: Int = 0) -> String  {
        var script = ""
        for edgeDef in edgeDefs {
            script += edgeDef.scriptVal()
        }
        if script.isEmpty { return "" }
        else { return script.with(trailing:" ") }
    }
    func dumpScript(_ tr3:Tr3) -> String  {
        var script = ""
        for edgeDef in edgeDefs {
            script += edgeDef.scriptVal()
        }
        if script.isEmpty { return "" }
        else { return script.with(trailing:" ") }
    }

    /// connect direct or ternary edges
    func bindEdges(_ tr3:Tr3) {
        for edgeDef in edgeDefs {
            edgeDef.connectEdges(tr3)
        }
    }
}
