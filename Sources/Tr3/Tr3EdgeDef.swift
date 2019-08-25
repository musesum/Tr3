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
            // dont overwrite path val with nl
            if let _ = pathDict[path] {
                if val_ == nil {
                    return
                }
            }
            pathDict[path] = val_
            pathList.append(path)
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
    //var defPaths = [String]() // b in a <- b
    //var defVals = [Tr3Val?]() // 9 in a -> (b:9)
    var edges = [String:Tr3Edge]() // each edge is also shared by two Tr3s

    // currently ternary in ternary tree to parse
    var parseTern: Tr3ValTern? // * in a -> (a ? * ? * ? * : * : *)
    
    init() { }

    init(flags: Tr3EdgeFlags) { self.edgeFlags = flags }

    init(with: Tr3EdgeDef) {

        edgeFlags = with.edgeFlags
        for path in with.pathVals.pathList { // pathVals = with.pathVal
            switch with.pathVals.pathDict[path] {
            case let v as Tr3ValTern   : pathVals.add(path, Tr3ValTern  (with: v))
            case let v as Tr3ValScalar : pathVals.add(path, Tr3ValScalar(with: v))
            case let v as Tr3ValTuple  : pathVals.add(path, Tr3ValTuple (with: v))
            case let v as Tr3ValQuote  : pathVals.add(path, Tr3ValQuote (with: v))
            default: break
            }
        }
        ternVal = with.ternVal?.copy()
    }

    func copy() -> Tr3EdgeDef {
        return Tr3EdgeDef(with: self)
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
