//
//  Tr3EdgeDefs.swift
//  Par iOS
//
//  Created by warren on 4/28/19.
//

import Foundation

public class Tr3EdgeDefs {

    var edgeDefs = [Tr3EdgeDef]()

    convenience init(with: Tr3EdgeDefs) {
        self.init()
        for edgeDef in with.edgeDefs {
            edgeDefs.append(edgeDef.copy())
        }
    }
    func copy() -> Tr3EdgeDefs {
        let newEdgeDefs = Tr3EdgeDefs(with: self)
        return newEdgeDefs
    }

    /// override old ternary with new value
    public func overideEdgeTernary(_ tern_:Tr3ValTern) -> Bool {

        for edgeDef in edgeDefs {
            if let ternPath = edgeDef.ternVal?.path,
                ternPath == tern_.path {

                edgeDef.ternVal = tern_.copy()
                return true
            }
        }
        return false
    }
    func merge(_ merge:Tr3EdgeDefs) {

        func isUnique(_ mergeDef: Tr3EdgeDef) -> Bool {
            for edgeDef in edgeDefs {
                if edgeDef == mergeDef { return false }
            }
            return true
        }

        // begin ----------------------
        for mergeDef in merge.edgeDefs {
            if isUnique(mergeDef) {
                edgeDefs = merge.edgeDefs //???? .append(mergeDef)
                break
            }
            if let mergeTernVal = mergeDef.ternVal {
                if !overideEdgeTernary(mergeTernVal) {
                    addEdgeTernary(mergeTernVal)
                }
            }
        }
    }
    /// add ternary to array of edgeDefs
     public func addEdgeTernary(_ tern_:Tr3ValTern, copyFrom: Tr3? = nil) {

         if let lastEdgeDef = edgeDefs.last {

             if let lastTern = lastEdgeDef.ternVal {
                 lastTern.deepAddVal(tern_)
             }
             else {
                 lastEdgeDef.ternVal = tern_
                 Tr3ValTern.ternStack.append(tern_)
             }
         }
             // copy edgeDef from search z in
         else if let copyEdgeDef = copyFrom?.edgeDefs.edgeDefs.last {

             let newEdgeDef = Tr3EdgeDef(with:copyEdgeDef)
             edgeDefs.append(newEdgeDef)
             newEdgeDef.ternVal = tern_
             Tr3ValTern.ternStack.append(tern_)
         }
         else {

             print("*** \(#function) no edgeDefs to add edge")
         }
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
