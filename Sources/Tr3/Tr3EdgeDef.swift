//
//  Tr3EdgeDef.swift
//  Par iOS
//
//  Created by warren on 3/10/19.
//

import Foundation
import Par // ParAny 


/// keeps a dictionary of paths as keys with Tr3Vals,
/// plus keeps array of paths to preserve sequence,
/// which is important for preserving order of values
struct PathVals {

    var pathDict = [String:Tr3Val?]() // eliminate duplicates
    var pathList = [String]()         // preserve sequence order

    mutating func add(_ path: String?, _ val_: Tr3Val?) {
        if let path = path {
            if let _ = pathDict[path] {
                if val_ == val_ {  // dont overwrite path val with nil
                     pathDict[path] = val_
                }
                return
            }
            else  {
                pathDict[path] = val_
                pathList.append(path)
            }
        }
    }
    static func == (lhs: PathVals, rhs: PathVals) -> Bool {

        for lkey in lhs.pathList {
            if lhs.pathDict[lkey] == rhs.pathDict[lkey]  { continue }
            return false
        }
        return true
    }
}

public class Tr3EdgeDef {

    var edgeFlags = Tr3EdgeFlags()
    var pathVals = PathVals()
    var ternVal: Tr3ValTern?
    var edges = [String:Tr3Edge]() // each edge is also shared by two Tr3s
    
    init() { }

    init(flags: Tr3EdgeFlags) {
        self.edgeFlags = flags
    }
    
    init(with: Tr3EdgeDef) {
        
        edgeFlags = with.edgeFlags
        for path in with.pathVals.pathList { // pathVals = with.pathVal
            if let val = with.pathVals.pathDict[path] {
                switch val {
                case let val as Tr3ValTern   : pathVals.add(path, val.copy())
                case let val as Tr3ValScalar : pathVals.add(path, val.copy())
                case let val as Tr3ValTuple  : pathVals.add(path, val.copy())
                case let val as Tr3ValQuote  : pathVals.add(path, val.copy())
                default                      : pathVals.add(path, val)
                }
            }
        }
        ternVal = with.ternVal?.copy()
    }

    func copy() -> Tr3EdgeDef {
        let newEdgeDef = Tr3EdgeDef(with: self)
        return newEdgeDef
    }
    
    func addPath(_ parAny:ParAny) {

        if let path = parAny.next.first?.value {

            if let _ = ternVal {
                Tr3ValTern.ternStack.last?.addPath(path)
            }
            else {
                pathVals.add(path,nil)
            }
        }
        else {
            print("*** Tr3EdgeDef: \(self) cannot process addPath(\(parAny))")
        }
    }

    static func == (lhs: Tr3EdgeDef, rhs: Tr3EdgeDef) -> Bool {
        return lhs.pathVals == rhs.pathVals
    }

}
