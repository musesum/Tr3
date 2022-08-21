//
//  File.swift
//  
//
//  Created by warren on 3/10/21.
//

import Foundation
import Collections

/** keeps track of Tr3Vals

    - pathDict: dictionary of path
    - pathList: preserve sequence order
 */
class PathVals {

    var pathDict: OrderedDictionary<String,Tr3Val?> = [:] // eliminate duplicates

    func add(path: String = "", val: Tr3Val?) { 
        if path.count > 0 {
            if pathDict.keys.isEmpty {
                pathDict[path] = val
            }
            else if let tuple = pathDict[path] as? Tr3Exprs,
                    let scalar = val as? Tr3ValScalar {
                    tuple.addScalar(scalar)
            } else {
                pathDict[path] = val
            }
        } else if let lastPath = pathDict.keys.last {
            pathDict[lastPath] = val
        } else {
            pathDict[path] = val
 //???           print("🚫 PathVals::add unhandled path:\(path ?? "nil") val:\(val?.scriptVal(expand: true) ?? "nil")")
        }
    }
    static func == (lhs: PathVals, rhs: PathVals) -> Bool {

        for (key,val) in lhs.pathDict {
            if val == rhs.pathDict[key]  { continue }
            return false
        }
        return true
    }
}
