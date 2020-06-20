//
//  File.swift
//  
//
//  Created by warren on 9/13/19.
//

import Foundation

#if false
/// currently cannot bundle resource with Swift package

func parseFile(_ fileName: String) -> Bool {
    if tr3Parse.parseTr3(root,fileName) {
        return 0
    }
    else {
        return 1
    }
}

func testInherit() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
    var err = 0
    let root = Tr3("√")
    err += parseFile("multiline")
    err += parseFile("multimerge")
    let actual = root.makeScript()
    print(actual)
    XCTAssertEqual(err,0)
}


func testSky() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

    var err = 0
    let root = Tr3("√")
    func parseFile(_ fileName: String) { tr3Parse.parseTr3(root,fileName) }


    err += parseFile("sky.main")
    err += parseFile("sky.shader")
    err += parseFile("panel.cell")
    err += parseFile("panel.cell.fader")
    err += parseFile("panel.cell.fredkin")
    err += parseFile("panel.cell.timeTunnel")
    err += parseFile("panel.cell.zhabatinski")
    err += parseFile("panel.cell.melt")
    err += parseFile("panel.cell.average")
    err += parseFile("panel.cell.slide")
    err += parseFile("panel.cell.brush")
    err += parseFile("panel.shader.colorize")
    err += parseFile("panel.cell.scroll")
    err += parseFile("panel.shader.tile")
    err += parseFile("panel.speed")

    // aways last to connect ruleOn, value state between dots

    let actual = root.makeScript(0,pretty: true)
    let planned = ReadFile(SkyExpectedResult) // copy the 

    err += ParStr.testCompare(planned, actual, echo: true)
    //print(actual)
    let d3Script = root.makeD3Script()
    print(d3Script)
    XCTAssertEqual(err,0)
}
#endif
