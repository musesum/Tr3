//  Tr3ValTern+runtime.swift
//
//  Created by warren on 4/11/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par // visitor

extension Tr3ValTern {

    func changeState(_ state:   Tr3TernState,
                     _ prevTr3: Tr3,
                     _ nextTr3: Tr3,
                     _ act:     Tr3Act,
                     _ visitor: Visitor) {

        func setTernEdges(_ val: Tr3Val?, active: Bool) {

            if let valPath = val as? Tr3ValPath {
                for pathTr3 in  valPath.pathTr3s  {
                    for pathEdge in pathTr3.tr3Edges.values {
                        if pathEdge.rightTr3 == tr3 {
                            pathEdge.active = active
                        }
                    }
                }
            }
        }

        func forTernPathVal(_ val: Tr3Val?, callTern: @escaping CallTern) {

            if let pathTr3s = (val as? Tr3ValTern)?.pathTr3s {
                for pathTr3 in pathTr3s {
                    if let tern = pathTr3.val as? Tr3ValTern {
                        callTern(tern)
                    }
                }
            }
        }
        func recalcPathVal(_ val: Tr3Val?) {

            if  let tern = val as? Tr3ValTern {
                tern.recalc(prevTr3, nextTr3, act, visitor)
            }
            else if act != .sneak {
                _ = tr3.setEdgeVal(val, visitor)
            }
        }
        func neitherPathVal(_ val: Tr3Val?) {
            forTernPathVal(val) { tern in
                tern.changeState(.noVal, prevTr3, nextTr3, act, visitor)
            }
        }

        // ────────────── begin ──────────────

        ternState = state
        switch ternState {

        case .thenVal:
            // b1, b2, b3 in `x <- (a ? (b1 ? b2 : b3) : c)`
            setTernEdges(thenVal, active: true)
            setTernEdges(elseVal, active: false)
            recalcPathVal(thenVal)
            neitherPathVal(elseVal)

        case .elseVal:
            // c1, c2, c3 in `x <- (a ? b : (c1 ? c2 : c3))`
            setTernEdges(thenVal, active: false)
            setTernEdges(elseVal, active: true)
            neitherPathVal(thenVal)
            recalcPathVal(elseVal)

        case .noVal:

            setTernEdges(thenVal, active: false)
            setTernEdges(elseVal, active: false)
            neitherPathVal(thenVal)
            neitherPathVal(elseVal)
            recalcPathVal(thenVal)
            recalcPathVal(elseVal)

        default: break
        }
    }

    // follow radio linked list to beginnning and change state along the way
    func changeRadio(_ prevTr3: Tr3,
                     _ nextTr3: Tr3,
                     _ visitor: Visitor) {

        for radioTr3 in pathTr3s {
            if let tern = radioTr3.val as? Tr3ValTern {
                tern.changeState(.noVal, prevTr3, nextTr3, .sneak, visitor)
            }
            if let thenPath = thenVal as? Tr3ValPath {
                for thenTr3 in thenPath.pathTr3s {
                    for edge in thenTr3.tr3Edges.values {
                        if      edge.leftTr3 == thenTr3, edge.rightTr3 == nextTr3 { edge.active = false }
                        else if edge.leftTr3 == nextTr3, edge.rightTr3 == thenTr3 { edge.active = false }
                    }
                }
            }
            if let elsePath = elseVal as? Tr3ValPath {
                for elseTr3 in elsePath.pathTr3s {
                    for edge in elseTr3.tr3Edges.values {
                        if      edge.leftTr3 == elseTr3, edge.rightTr3 == nextTr3 { edge.active = false }
                        else if edge.leftTr3 == nextTr3, edge.rightTr3 == elseTr3 { edge.active = false }
                    }
                }
            }
        }
    }
    // follow radio linked list to beginnning and change state along the way
    func changeRadioPrev(_ prevTr3: Tr3,
                         _ nextTr3: Tr3,
                         _ visitor: Visitor) {

        changeRadio(prevTr3, nextTr3, visitor)
        radioPrev?.changeRadioPrev(prevTr3, nextTr3, visitor)
    }

    // follow radio linked list to beginnning and change state along the way
    func changeRadioNext(_ prevTr3: Tr3,
                         _ nextTr3: Tr3,
                         _ visitor: Visitor) {

        changeRadio(prevTr3, nextTr3, visitor)
        radioNext?.changeRadioNext(prevTr3, nextTr3, visitor)
    }

    func recalc(_ prevTr3: Tr3?,
                _ nextTr3: Tr3?,
                _ act:     Tr3Act,
                _ visitor: Visitor) {

        guard let prevTr3 else { print("🚫 prevTr3 = nil"); return }
        guard let nextTr3 else { print("🚫 nextTr3 = nil"); return }
        // a in `w <-(a ? x : y)`
        // a in `w <-(a == b ? x : y)`  when a == b
        if testCondition(prevTr3, act) {

            radioPrev?.changeRadioPrev(prevTr3, nextTr3, visitor)
            radioNext?.changeRadioNext(prevTr3, nextTr3, visitor)
            changeState(.thenVal, prevTr3, nextTr3, act, visitor)
        }
            // during bindTerns, deactivate edges when there is no value or comparison
        else if act == .sneak {
            // deactive both Then, Else edges
            radioPrev?.changeRadioPrev(prevTr3, nextTr3, visitor)
            radioNext?.changeRadioNext(prevTr3, nextTr3, visitor)
            changeState(.noVal, prevTr3, nextTr3, act, visitor) // a ?? b fails comparison
        }
            // when a != b in `w <-(a == b ? x : y)`
        else {
            changeState(.elseVal, prevTr3, nextTr3, act, visitor) // a ?? b fails comparison
        }
    }

    /// set destination to source value
    func setTr3Val(_ left:    Tr3,
                   _ right:   Tr3,
                   _ act:     Tr3Act,
                   _ visitor: Visitor) {

        // DebugPrint("dst:%s src:%s \n&src.val:%p \n&event.val:%p\n\n", dst.name.c_str(), src.name.c_str(), src.val, event.val)

        var isOk = true // test if setVal conditionals passed
        if left.passthrough {
            left.val = right.val
        }
        else {
            isOk = left.val?.setVal(right.val!, visitor) != nil
        }
        if act == .activate, isOk {
            left.activate(visitor)
        }
    }

}
