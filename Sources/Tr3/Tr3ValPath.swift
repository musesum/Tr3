//  Tr3ValPath.swift
//
//  Created by warren on 4/23/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par // Visitor

public class Tr3ValPath: Tr3Val {

    @objc  var path = ""
    var pathTr3s = [Tr3]()

    override init(_ tr3: Tr3, _ name: String) {
        super.init(tr3, name)
    }

    init(_ tr3: Tr3, with path: String) {
        super.init(tr3, path)
        self.path = path
    }
    
    init(with: Tr3ValPath) {
        super.init(with: with)
        path = with.path
        // copy only path definition; not edges, which are relative to Tr3's position in hierarchy
        // pathTr3s  = with.pathTr3s
    }

    public static func == (lhs: Tr3ValPath, rhs: Tr3ValPath) -> Bool {
        return lhs.path == rhs.path
    }


    public override func printVal() -> String {

        if pathTr3s.isEmpty {
            return path
        }
        else {
            var script = pathTr3s.count > 1 ? "(" : ""

            for pathTr3 in pathTr3s {
                script.spacePlus(pathTr3.val?.printVal() ?? pathTr3.name)
            }
            if pathTr3s.count > 1 { return script.with(trailing: ")") }
            else                  { return script }
        }
    }
    public override func scriptVal(_ scriptFlags: Tr3ScriptFlags = [.parens]) -> String {
        
        if scriptFlags.expand {
            var script = Tr3.scriptTr3s(pathTr3s)
            if script.first != "(" {
                script = "(\(script))"
            }
            return script
        } else {
            return path
        }
    }

    override func copy() -> Tr3ValPath {
        let newTr3ValPath = Tr3ValPath(with: self)
        return newTr3ValPath
    }

    public override func setVal(_ any: Any?,
                                _ visitor: Visitor,
                                _ options: Tr3SetOptions? = nil) -> Bool {
        //TODO: is ever used during runtime?
        return true
    }

    public override func getVal() -> Any {
        return path
    }

}
