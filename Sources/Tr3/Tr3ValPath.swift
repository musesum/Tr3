//  Tr3ValPath.swift
//
//  Created by warren on 4/23/19.
//  Copyright © 2019 Muse Dot Company
//  License: Apache 2.0 - see License file

import Foundation

public class Tr3ValPath: Tr3Val {

    var path = ""
    var pathTr3s = [Tr3]()

    override init() {
        super.init()
    }

    init(with path_: String) {
        super.init()
        path = path_
    }
    init(with: Tr3ValPath) {
        super.init(with: with)
        path = with.path
        // copy only path definition; not edges, which are relative to Tr3's position in hierarchy
        // pathTr3s  = with.pathTr3s
    }
    override func copy() -> Tr3ValPath {
        let newTr3ValPath = Tr3ValPath(with: self)
        return newTr3ValPath
    }
    public static func == (lhs: Tr3ValPath, rhs: Tr3ValPath) -> Bool {
        return lhs.path == rhs.path
    }
    override func printVal() -> String {

        if pathTr3s.isEmpty {
            return path
        }
        else {
            var script = pathTr3s.count > 1 ? "(" : ""

            for pathTr3 in pathTr3s {
                script += script.parenSpace() + (pathTr3.val?.printVal() ?? pathTr3.name)
            }
            if pathTr3s.count > 1 { return script.with(trailing:")") }
            else                  { return script.with(trailing:" ") }
        }
    }
    override func scriptVal(parens: Bool = true) -> String  {
        return path.with(trailing:" ")
    }
    override func dumpVal(parens: Bool = true, session: Bool = false) -> String  {
        var script = Tr3.dumpTr3s(pathTr3s)
        if script.first == " " { script.removeFirst() }
        if script.first != "(" {
            script = "(\(script))"
        }
       return script.with(trailing: " ")
    }
    public override func setVal(_ any: Any?,_ options: Any? = nil) {
         //TODO: is ever used during runtime?
    }

}
