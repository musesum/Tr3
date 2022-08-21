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
        if path.isEmpty {
            if let lastKey = pathDict.keys.last {
                pathDict[lastKey] = val
            } else {
                //??? pathDict[path] = val
            }
        } else {
            if pathDict.keys.isEmpty {
                pathDict[path] = val
            }
            else if let exprs = pathDict[path] as? Tr3Exprs,
                    let scalar = val as? Tr3ValScalar {

                exprs.addScalar(scalar)

            } else {
                pathDict[path] = val
            }
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
