//
//  Tr3Edge.swift
//
//  Created by warren on 3/10/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par

public class Tr3Edge: Hashable {

    var id = Visitor.nextId()
    var key = "not yet"

    var edgeFlags = Tr3EdgeFlags()
    var active = true
    var leftTr3: Tr3?
    var rightTr3: Tr3?
    var defVal: Tr3Val?

    public static var LineageDepth = 2 // useful for debugging

    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

    public static func == (lhs: Tr3Edge, rhs: Tr3Edge) -> Bool {
        return lhs.key == rhs.key
    }

    convenience init(with: Tr3Edge) { // was operator = in c++ version
        self.init()
        edgeFlags = with.edgeFlags
        active    = with.active
        leftTr3   = with.leftTr3
        rightTr3  = with.rightTr3
        defVal    = with.defVal
        makeKey()
    }

    convenience init (_ leftTr3_: Tr3?, _ rightTr3_: Tr3?, _ edgeflags_: Tr3EdgeFlags) {
        self.init()
        edgeFlags = edgeflags_
        leftTr3   = leftTr3_
        rightTr3  = rightTr3_
        makeKey()
    }
    convenience init (_ def_: Tr3EdgeDef, _ leftTr3_: Tr3, _ rightTr3_: Tr3, _ tr3Val: Tr3Val?) {
        self.init()
        edgeFlags = def_.edgeFlags
        leftTr3   = leftTr3_
        rightTr3  = rightTr3_
        defVal    = tr3Val
        makeKey()
    }
    func makeKey() {
        let lhs = "\(leftTr3?.id ?? -1)"
        let rhs = "\(rightTr3?.id ?? -1)"
        let arrow = scriptEdgeFlag()
        key = lhs+arrow+rhs
    }
    func dumpVal(_ tr3: Tr3, session: Bool = false) -> String {

        var script = ""

        if leftTr3 == tr3, let rightTr3 = rightTr3 {
            script += rightTr3.scriptLineage(Tr3Edge.LineageDepth)
        }
        else if rightTr3 == tr3, let leftTr3 = leftTr3 {
            script += leftTr3.scriptLineage(Tr3Edge.LineageDepth)
        }
        script += defVal?.dumpVal(session: session).with(trailing: " ") ?? " "
        return script
    }

}
