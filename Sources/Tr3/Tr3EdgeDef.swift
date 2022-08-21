//  Tr3EdgeDef.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par // ParItem 

public class Tr3EdgeDef {

    var edgeFlags = Tr3EdgeFlags()
    var pathVals = PathVals()
    var ternVal: Tr3ValTern?
    var edges = [String: Tr3Edge]() // each edge is also shared by two Tr3s
    
    init() { }

    init(flags: Tr3EdgeFlags) {
        self.edgeFlags = flags
    }
    
    init(with fromDef: Tr3EdgeDef) {
        
        edgeFlags = fromDef.edgeFlags
        for (path,val) in fromDef.pathVals.pathDict { // pathVals = with.pathVal
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

}
