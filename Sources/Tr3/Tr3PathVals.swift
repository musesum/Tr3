//
//  File.swift
//  
//
//  Created by warren on 3/10/21.
//

import Foundation

/** keeps track of Tr3Vals

    - pathDict: dictionary of path
    - pathList: preserve sequence order
 */
class PathVals {

    var pathDict = [String: Tr3Val?]() // eliminate duplicates
    var pathList = [String]()         // preserve sequence order

    func add(path: String? = nil, val: Tr3Val?) {
        if let path = path {
            if !pathDict.keys.contains(path) {
                pathList.append(path)
            }
            if pathDict.keys.isEmpty {
                pathDict[path] = val
            }
            else if let tuple = pathDict[path] as? Tr3Exprs,
                    let scalar = val as? Tr3ValScalar {
                    tuple.addScalar(scalar)
            } else {
                pathDict[path] = val
            }
        } else if let lastPath = pathList.last, val != nil {
            pathDict[lastPath] = val
        } else {
            print("🚫 PathVals::add unhandled path:\(path ?? "nil") val:\(val?.dumpVal() ?? "nil")")
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
