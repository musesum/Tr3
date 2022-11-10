//  Tr3EdgeDef.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par // ParItem 

public class Tr3EdgeDef {

    var edgeFlags = Tr3EdgeFlags()
    var pathVals = Tr3PathVals()
    var ternVal: Tr3ValTern?
    var edges = [String: Tr3Edge]() // each edge is also shared by two Tr3s
    
    init() { }

    init(flags: Tr3EdgeFlags) {
        self.edgeFlags = flags
    }
    
    init(with fromDef: Tr3EdgeDef) {
        
        edgeFlags = fromDef.edgeFlags
        for (path,val) in fromDef.pathVals.pathVal { // pathVals = with.pathVal
            switch val {
                case let val as Tr3ValTern:   pathVals.add(path: path, val: val.copy())
                case let val as Tr3ValScalar: pathVals.add(path: path, val: val.copy())
                case let val as Tr3Exprs:     pathVals.add(path: path, val: val.copy())
                default:                      pathVals.add(path: path, val: val)
            }
        }
        ternVal = fromDef.ternVal?.copy()
    }
    
    func copy() -> Tr3EdgeDef {
        let newEdgeDef = Tr3EdgeDef(with: self)
        return newEdgeDef
    }
    func addLastPath(_ lastPath: String, val: Tr3Val) {
        
    }
    func addPath(_ parItem: ParItem) {

        if let path = parItem.nextPars.first?.value {

            if let _ = ternVal {
                Tr3ValTern.ternStack.last?.addPath(path)
            }
            else {
                pathVals.add(path: path, val: nil)
            }
        }
        else {
            print("🚫 Tr3EdgeDef: \(self) cannot process addPath(\(parItem))")
        }
    }

    static func == (lhs: Tr3EdgeDef, rhs: Tr3EdgeDef) -> Bool {
        return lhs.pathVals == rhs.pathVals
    }

    public func printVal() -> String {
        return scriptVal([.parens,.now,.expand])
    }
    
    public func scriptVal(_ scriptFlags: Tr3ScriptFlags) -> String{
        
        var script = edgeFlags.script()
        
        if let tern = ternVal {
            script.spacePlus(tern.scriptVal(scriptFlags))
        }
        else {
            if pathVals.pathVal.count > 1 { script += "(" }
            for (path,val) in pathVals.pathVal {
                script += path
                var scriptFlags2: Tr3ScriptFlags = [.parens]
                if scriptFlags.contains(.expand) {
                    scriptFlags2.insert(.expand)
                }
                script += val?.scriptVal(scriptFlags2) ?? ""
            }
            if pathVals.pathVal.count > 1 { script += ")" }
        }
        return script
    }
    
}
