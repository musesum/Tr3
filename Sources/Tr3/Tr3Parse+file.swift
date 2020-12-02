//  Tr3Parse+file.swift
//
//  Created by warren on 9/11/19.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

import Foundation
import Par

class BundleResource {

    let resourcePath = "../Resources"
    let name: String
    let type: String

    init(name: String, type: String) {
        self.name = name
        self.type = type
    }

    var path: String {
        let bundle = Bundle(for: Swift.type(of: self))
        guard let path = bundle.path(forResource: name, ofType: type) else {
            let filename: String = type.isEmpty ? name : "\(name).\(type)"
            let fullPath = resourcePath + "/" + filename
            return fullPath
        }
        return path
    }
}

public extension Tr3Parse {

    func read(_ filename: String, _ ext: String) -> String {

        let resource = BundleResource(name: filename, type: ext)
        do {
            let resourcePath = resource.path
            return try String(contentsOfFile: resourcePath) }
        catch {
            print("*** ParStr::\(#function) error:\(error) loading contents of:\(resource.path)")
        }
        return ""
    }

    @discardableResult
    func parseTr3(_ tr3: Tr3, _ filename: String) -> Bool {
        let script = read(filename,"tr3")
        print(filename, terminator:" ")
        let success = parseScript(tr3, script)
        if success  { print("✓") }
        else        { print("🚫 parse failed") }
        return success
    }

}
