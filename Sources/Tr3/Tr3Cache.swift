//
//  File.swift
//  
//
//  Created by warren on 7/17/19.
//

import Foundation
import Par

struct Tr3OptVisit {
    var tr3: Tr3
    var opt: Tr3SetOptions
    var visit: Visitor
}


/// double buffer list of cache items
public class Tr3Cache {

    static var caches = [[Tr3OptVisit](),[Tr3OptVisit]()]
    static var input = 0
    static var output = 1
    static var flushing = false

    
    static func flip() {
        input  ^= 1
        output ^= 1
    }

    static func flush() {

        if flushing == false {
            flushing = true

            flip()
            let cache = caches[output]
            for tov in cache {

                tov.tr3.flushCache(tov.opt,tov.visit)
            }
            flushing = false
        }
    }

    static func add(_ tr3:Tr3,_ opt:Tr3SetOptions,_ visitor:Visitor) {
        let tov = Tr3OptVisit(tr3:tr3,opt:opt,visit:visitor)
        caches[input].append(tov)
    }


}



