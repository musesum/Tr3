//
//  File.swift
//  
//
//  Created by warren on 12/27/20.
//

import Foundation

extension Dictionary {
    func += <K, V> (left: inout [K:V], right: [K:V]) {
        for (k, v) in right {
            left[k] = v
        }
    }
}
extension Array {
    func += <V> (left: inout [V], right: [V]) {
        for v in right {
            left.append(v)
        }
    }
}
