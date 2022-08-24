//  Created by warren on 3/10/21.
//

import Foundation
import Collections

class Tr3PathVals {

    var pathVal: OrderedDictionary<String,Tr3Val?> = [:] // eliminate duplicates

    func add(path: String = "", val: Tr3Val?) {
        if path.isEmpty {
            if let lastKey = pathVal.keys.last {
                pathVal[lastKey] = val
            } else {
                pathVal[path] = val
            }
        } else {
            if pathVal.keys.isEmpty {
                pathVal[path] = val
            }
            else if let exprs = pathVal[path] as? Tr3Exprs,
                    let scalar = val as? Tr3ValScalar {

                exprs.addScalar(scalar)

            } else {
                pathVal[path] = val
            }
        }
    }
    static func == (lhs: Tr3PathVals, rhs: Tr3PathVals) -> Bool {

        for (key,val) in lhs.pathVal {
            if val == rhs.pathVal[key]  { continue }
            return false
        }
        return true
    }
}
