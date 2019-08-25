//
//  Tr3EdgeDef.swift
//  Par iOS
//
//  Created by warren on 3/10/19.
//

import Foundation
import Par // ParAny 

struct PathVal {
    var path: String!
    var val: Tr3Val?
}
struct PathVals {

    var pathVals = [PathVal]()

    mutating func add(_ path: String?, _ val: Tr3Val?) {
        if let path = path {
            let pathVal = PathVal(path:path,val:val)
            pathVals.append(pathVal)
        }
    }
    static func == (lhs: PathVals, rhs: PathVals) -> Bool {
        // this is Ot(n²) for a very small n
        func findRight(_ lh:PathVal) -> Bool {
            for rh in rhs.pathVals {
                if rh.path == lh.path {
                    // both have values or nil
                    if lh.val == nil && rh.val == nil { return true }
                    if lh.val != nil && rh.val != nil { return true }
                }
            }
            return false
        }
        for lh in lhs.pathVals {
            if findRight(lh) { continue }
            return false
        }
        return true
    }
}

public class Tr3EdgeDef {

    var edgeFlags = Tr3EdgeFlags()
    var defPathVals = PathVals()
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
        for pathVal in with.defPathVals.pathVals { // defPathVals = with.defPathVals

            let p = pathVal.path
            let v = pathVal.val

            switch v {
            case let v as Tr3ValTern   : defPathVals.add(p,Tr3ValTern  (with: v))
            case let v as Tr3ValScalar : defPathVals.add(p,Tr3ValScalar(with: v))
            case let v as Tr3ValTuple  : defPathVals.add(p,Tr3ValTuple (with: v))
            case let v as Tr3ValQuote  : defPathVals.add(p,Tr3ValQuote (with: v))
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
                defPathVals.add(path,nil)
            }
        }
        else {
            print("*** Tr3EdgeDef: \(self) cannot process addPath(\(parAny))")
        }
    }

    static func == (lhs: Tr3EdgeDef, rhs: Tr3EdgeDef) -> Bool {
        return lhs.defPathVals == rhs.defPathVals
    }

}
