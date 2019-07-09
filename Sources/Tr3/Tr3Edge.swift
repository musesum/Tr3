//
//  Tr3Edges.swift
//  Par iOS
//
//  Created by warren on 3/10/19.
//

import Foundation

public class Tr3Edge {

    static var nextId = 0
    static func getNextId() -> Int { nextId += 1 ; return nextId }
    var id = Tr3.getNextId()

    var edgeFlags = Tr3EdgeFlags()
    var active    = true
    var leftTr3   : Tr3?
    var rightTr3  : Tr3?
    var defVal    : Tr3Val?

    static func == (lhs:Tr3Edge, rhs:Tr3Edge) -> Bool {

        if  lhs.leftTr3?.id == rhs.leftTr3?.id,
            lhs.edgeFlags.rawValue == rhs.edgeFlags.rawValue {

            return true
        }
        return false
    }

    convenience init(with: Tr3Edge) { // was operator = in c++ version
        self.init()
        edgeFlags = with.edgeFlags
        active    = with.active
        leftTr3   = with.leftTr3
        rightTr3  = with.rightTr3
        defVal    = with.defVal
    }

    convenience init (_ leftTr3_: Tr3?,_ rightTr3_:Tr3?,_ edgeflags_:Tr3EdgeFlags) {
        self.init()
        edgeFlags = edgeflags_
        leftTr3   = leftTr3_
        rightTr3  = rightTr3_
    }
    convenience init (_ def_: Tr3EdgeDef,_ leftTr3_:Tr3,_ rightTr3_: Tr3) {
        self.init()
        edgeFlags = def_.edgeFlags
        leftTr3   = leftTr3_
        rightTr3  = rightTr3_
        defVal    = def_.defVal
    }
    func dumpVal(_ tr3:Tr3, session:Bool = false) -> String {

        var script = ""

        if leftTr3 == tr3, let rightTr3 = rightTr3 {
            script += rightTr3.scriptLineage(2)
        }
        else if rightTr3 == tr3, let leftTr3 = leftTr3 {
            script += leftTr3.scriptLineage(2)
        }
        script += defVal?.dumpVal(session:session).with(trailing: " ") ?? " "
        return script
    }

}
