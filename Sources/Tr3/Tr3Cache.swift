//
//  Tr3Cache.swift
//  
//  Created by warren on 7/17/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par

struct Tr3CacheItem {
    var tr3: Tr3
    var any: Any // value to set to Tr3.val
    var opt: Tr3SetOptions
    var visit: Visitor
}

/// double buffer list of cache items
public class Tr3Cache {

    static var cache = [[Tr3CacheItem](), [Tr3CacheItem]()]
    static var input = 0
    static var output = 1
    static var flushing = false

    /// Tr3Cache double buffers input and output
    static func flipInputOut() {
        input  ^= 1
        output ^= 1
    }

    public static func flush() {

        if flushing == false {

            flushing = true
            flipInputOut()
            let cacheOut = cache[output]

            for cache in cacheOut {

                let tr3 = cache.tr3
                let any = cache.any
                let opt = cache.opt
                let visit = cache.visit

                tr3.setAny(any, opt, visit)
            }
            flushing = false
        }
    }

    /// add an Tr3CacheItem to cache to be flushed during next frame update
    public static func add(_ tr3: Tr3, _ any: Any, _ opt: Tr3SetOptions, _ visitor: Visitor) {
        let cacheItem = Tr3CacheItem(tr3: tr3, any: any, opt: opt, visit: visitor)
        cache[input].append(cacheItem)
    }
}
