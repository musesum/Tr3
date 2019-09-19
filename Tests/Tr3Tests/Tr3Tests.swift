import XCTest
import Par

@testable import Tr3

class Resource {
    static var resourcePath = "./Tests/Resources"

    let name: String
    let type: String

    init(name: String, type: String) {
        self.name = name
        self.type = type
    }

    var path: String {
        guard let path: String = Bundle(for: Swift.type(of: self)).path(forResource: name, ofType: type) else {
            let filename: String = type.isEmpty ? name : "\(name).\(type)"
            return "\(Resource.resourcePath)/\(filename)"
        }
        return path
    }
}

final class Tr3Tests: XCTestCase {

    var tr3Parse = Tr3Parse()

    /// Test script produces expected output
    /// - parameter script: test script
    /// - parameter expected: exected output after parse
    ///
    func test(_ script:String,_ expected:String, session:Bool = false) -> Int {

        var err = 0

        print(script)
        let root = Tr3("√")

        if tr3Parse.parseScript(root,script, whitespace: "\n\t ") {

            let actual = root.dumpScript(session:session)
            err = ParStr.testCompare(expected,actual)
        }
        else  {
            print(" 🚫 failed parse")
            err += 1  // error found
        }
        return err
    }
    func testParseShort() {

        var err = 0

        err += test("a.b.c:(0...1=0) z:a { b.c:(0...1=1) }",
                    "√ { a { b { c:(0...1=0) } } z { b { c:(0...1=1) } } }")

        err += test("a {b c}:{d e}:{f g}:{h i} z -> a.b˚g.h",
                    "√ { a { b { d { f { h i } g { h i } } e { f { h i } g { h i } } } " +
                        "    c { d { f { h i } g { h i } } e { f { h i } g { h i } } } } " +
            " z->(d.g.h e.g.h) }")

        err += test("a b c a<-b a<-c","√ { a<-(b c) b c }")

        err += test("a {b c}:{d e f -> b:1} z:a z.b.f => c:1 ",
                    "√ { a { b { d e f->a.b:1 } c { d e f->a.b:1 } }" +
            "     z { b { d e f=>z.c:1 } c { d e f->z.b:1 } } }")

        err += test("a._c { d { e { f : \"ff\" } } } a.c.z : _c { d { e.f   : \"ZZ\" } }",
                    "√ { a { _c { d { e { f:\"ff\" } } } c { z { d { e { f:\"ZZ\" } } } } } }")

        err += test("a.b { _c { d e.f:(0...1=0) g} z:_c { g } } ",
                    "√ { a { b { _c { d e { f:(0...1=0) } g } z { d e { f:(0...1=0) } g } } } }")

        err += test("a.b._c {d:1} a.b.e:_c","√ { a { b { _c { d:1 } e { d:1 } } } }")

        err += test("a {b c}:{d e}:{f g}:{i j} a.b˚f <- (f.i ? f.j : 0) ",
                    "√ { a { b { d { f<-(f.i ? f.j : 0 ) { i?>b.d.f j->b.d.f } g { i j } }" +
                        "         e { f<-(f.i ? f.j : 0 ) { i?>b.e.f j->b.e.f } g { i j } } }" +
                        "     c { d { f { i j } g { i j } }" +
                        "         e { f { i j } g { i j } } } } a.b˚f<-(f.i ? f.j : 0 ) }" +
            "")

        err += test("a {b c}:{d <-(b ? 1 | c ? 2) e } z:a z.b.d <- (b ? 5 | c ? 6)",
                    "√ { a { b?>(a.b.d a.c.d) { d<-(b ? 1 | c ? 2) e } " +
                        "     c?>(a.b.d a.c.d) { d<-(b ? 1 | c ? 2) e } } " +
                        " z { b?>(z.b.d z.c.d) { d<-(b ? 5 | c ? 6) e } " +
                        "     c?>(z.b.d z.c.d) { d<-(b ? 1 | c ? 2) e } } }" +
            "")


        err += test("a b->a:1", "√ { a b->a:1 }")

        err += test("a <- (b c)", "√ { a <-(b c) }")

        err += test("a b.c <-(a ? 1) d:b ", "√ { a?>(b.c d.c) b { c<-(a ? 1 ) } d { c<-(a ? 1 ) } }")
        
        err += test("a {b <-(a ? 1) c} ", "√ { a?>a.b { b<-(a ? 1 ) c } }")
        
        err += test("a {b c}:{d <-(b ? 1 | c ? 2) e} ",
                    "√ { a { b?>(a.b.d a.c.d) { d<-(b ? 1 | c ? 2) e } " +
                        /**/"c?>(a.b.d a.c.d) { d<-(b ? 1 | c ? 2) e } } }")

        err += test("a b c w <-(a ? 1 : b ? 2 : c ? 3)",
                    "√ { a?>w b?>w c?>w w<-(a ? 1 : b ? 2 : c ? 3) }")

        err += test("a.b { c d } a.e:a.b { f g } ", "√ { a { b { c d } e { c d f g } } }")

        err += test(    "a { b c } d:a { e f } g:d { h i } j:g { k l }",
                        "√ { a { b c } d { b c e f } g { b c e f h i } j { b c e f h i k l } }")

        err += test("a { b c }    h:a { i j }","√ { a { b c } h { b c i j } }")
        err += test("a { b c } \n h:a { i j }","√ { a { b c } h { b c i j } }")

        XCTAssertEqual(err,0)
    }
    /// compare script with expected output and print an error if they don't match
    func testParseBasics() {

        var err = 0

        print("\n━━━━━━━━━━━━━━━━━━━━━━ quote ━━━━━━━━━━━━━━━━━━━━━━\n")
        err += test("a:\"yo\"", "√ { a:\"yo\" }")
        err += test("a { b:\"bb\" }", "√ { a { b:\"bb\" } }")
        err += test("a { b:\"bb\" c:\"cc\" }", "√ { a { b:\"bb\" c:\"cc\" } }")

        print("\n━━━━━━━━━━━━━━━━━━━━━ comment ━━━━━━━━━━━━━━━━━━━━━\n")
        err += test("a // yo","√ { a }")
        err += test("a { b } // yo","√ { a { b } }")
        err += test("a { b // yo \n } ", "√ { a { b } }")
        err += test("a { b { // yo \n c } } ", "√ { a { b { c } } }")
        err += test("// yo \na { b { c } }","√ { a { b { c } } }")
        err += test("// yo\n// oy\na { b { c } }","√ { a { b { c } } }")

        print("\n━━━━━━━━━━━━━━━━━━━━━━ hierarchy ━━━━━━━━━━━━━━━━━━━━━━\n")
        err += test("a { b c }","√ { a { b c } }")
        err += test("a { b { c } }","√ { a { b { c } } }")
        err += test("a { b { c } d { e } }","√ { a { b { c } d { e } } }")
        err += test("a { b { c d } e }","√ { a { b { c d } e } }")

        print("\n━━━━━━━━━━━━━━━━━━━━━━ many ━━━━━━━━━━━━━━━━━━━━━━\n")
        err += test("a {b c}:{d e}","√ { a { b { d e } c { d e } } }")
        err += test("a {b c}:{d e}:{f g}","√ { a { b { d { f g } e { f g } } c { d { f g } e { f g } } } }")
        
        XCTAssertEqual(err,0)
    }
    func testParseSkyControl() {
        var err = 0
        err += test("""
            _controlBase {

                base {
                    type  : "unknown"
                    title : "Unknown"
                    frame : (x:0 y:0 w:320 h:176)
                    icon  : "control.ring.white.png"
                }
                elements {

                    ruleOn  {
                        type  : "switch"
                        title : "Active"
                        frame : (x:266 y:6 w:48 h:32)
                        lag   : 0
                        value : (0...1=0)
                    }
                }
                //on <-> elements.ruleOn.value
            }
            _controlRule : _controlBase {

                base {
                    type  : "rule"
                    title : "Rule" // name
                    frame : (x:0 y:0 w:320 h:168)
                }

                elements {

                    version {
                        type  : "segment"
                        title : "Version"
                        frame : (x:70 y:52 w:192 h:44)
                        value : (1...2=1) //<-> cell.rule.<name>.version
                    }
                    fillZero {
                        type  : "trigger"
                        title : "clear 0"
                        frame : (x:10 y:108 w:44 h:44)
                        icon  : "control.drop.clear.png"
                        value : (0...1=0) -> sky.cell.rule.zero
                    }
                    fillOne {
                        type  : "trigger"
                        title : "clear 0xFFFF"
                        frame : (x:266 y:108 w:44 h:44)
                        icon  : "control.drop.gray.png"
                        value : (0...1=0) -> sky.cell.rule.one
                    }
                    plane  {
                        type  : "slider"
                        title : "Rule Plane"
                        frame : (x:70 y:108 w:192 h:44)
                        icon  : "control.pearl.white.png"
                        value : (0...1=0) -> control.shader˚uniform.shift
                    }
                }
            }
            """,
                    """
             √ { _controlBase { base { type:"unknown" title:"Unknown" frame:(x:0 y:0 w:320 h:176) icon:"control.ring.white.png" }
             elements { ruleOn { type:"switch" title:"Active" frame:(x:266 y:6 w:48 h:32) lag:0 value:(0...1=0) } } }
             _controlRule { base { type:"rule" title:"Rule" frame:(x:0 y:0 w:320 h:168) icon:"control.ring.white.png" }
                 elements {
                     ruleOn { type:"switch" title:"Active" frame:(x:266 y:6 w:48 h:32) lag:0 value:(0...1=0) }
                     version { type:"segment" title:"Version" frame:(x:70 y:52 w:192 h:44) value:(1...2=1) }
                     fillZero { type:"trigger" title:"clear 0" frame:(x:10 y:108 w:44 h:44) icon:"control.drop.clear.png" value:(0...1=0) -> sky.cell.rule.zero }
                     fillOne { type:"trigger" title:"clear 0xFFFF" frame:(x:266 y:108 w:44 h:44) icon:"control.drop.gray.png" value:(0...1=0) -> sky.cell.rule.one }
                     plane { type:"slider" title:"Rule Plane" frame:(x:70 y:108 w:192 h:44) icon:"control.pearl.white.png" value:(0...1=0) -> control.shader˚uniform.shift } } } }

             """)

        XCTAssertEqual(err,0)
    }
    func testParsePathProto() {
        var err = 0
        err += test("a.b.c { b { d } }", "√ { a { b { c { b { d } } } } }")
        err += test("a.b { c d } e:a { b.c:0 }", "√ { a { b { c d } } e { b { c:0 d } } }")
        err += test("a { b { c } } a.b <-> c ", "√ { a { b<->a.b.c { c } } } ")
        err += test("a { b { c d } } e { b { c d } b:0 }" , "√ { a { b { c d } } e { b:0 { c d } } }")

        err += test("a {b c}:{d e}:{f g}:{i j} a.b˚f <- (f.i ? f.j : 0) ",
                    "√ { a { b { d { f<-(f.i ? f.j : 0 ) { i?>b.d.f j->b.d.f } g { i j } }" +
                        "         e { f<-(f.i ? f.j : 0 ) { i?>b.e.f j->b.e.f } g { i j } } }" +
                        "     c { d { f { i j } g { i j } }" +
                        "         e { f { i j } g { i j } } } } a.b˚f<-(f.i ? f.j : 0 ) }" +
            "")

        XCTAssertEqual(err,0)
    }
    func testParseValues() {
        var err = 0
        print("\n━━━━━━━━━━━━━━━━━━━━━━ tr3 scalars ━━━━━━━━━━━━━━━━━━━━━━\n")
        err += test("a { b:2 { c } }","√ { a { b:2 { c } } }")
        err += test("a:1 { b:2 { c:3 } }","√ { a:1 { b:2 { c:3 } } }")
        err += test("a: 0...1=0.5 { b:(1...2) { c:(2..<3) } }","√ { a:(0...1=0.5) { b:(1...2) { c:(2..<3) } } }")
        err += test("a:%2 b:(%2)","√ { a:(%2) b:(%2) }")

        print("\n━━━━━━━━━━━━━━━━━━━━━━ tr3 tuples ━━━━━━━━━━━━━━━━━━━━━━\n")
        err += test("a:(x y):(0...1=0.5)","√ { a:(x y):(0...1=0.5) }")
        err += test("a:(x y):(1...2)","√ { a:(x y):(1...2) }")
        err += test("b:(x y):(-1. 2.)","√ { b:(x y):(-1 2) }")
        err += test("c:(x:3 y:+4)","√ { c:(x:3 y:4) }")
        err += test("d:(x y z)","√ { d:(x y z) }")
        err += test("m:(0 0 0) n->m:(1 1 1)", "√ { m:(0 0 0) n->m:(1 1 1) }")
        err += test("m:(0 0 0) n:(1 1 1)->m", "√ { m:(0 0 0) n:(1 1 1)->m }")

        err += test("e:(x y):(-16...16=0)","√ { e:(x y):(-16...16=0) }")
        err += test("f:(p q r):(0...1=0)","√ { f:(p q r):(0...1=0) }")
        err += test("g:(p q r):(0...1=0):(.5 .5 .5)","√ { g:(p q r):(0.5 0.5 0.5):(0...1=0) }")
        err += test("h:(p:0.5 q:0.5 r:0.5):(0...1=0)","√ { h:(p:0.5 q:0.5 r:0.5):(0...1=0) }")
        err += test("i:(0.5 0.5 0.5):(0...1=0)","√ { i:(0.5 0.5 0.5):(0...1=0) }")
        XCTAssertEqual(err,0)
    }
    func testParsePaths() { print("\n━━━━━━━━━━━━━━━━━━━━━━ paths ━━━━━━━━━━━━━━━━━━━━━━\n")
        var err = 0

        err += test("a { b { c {c1 c2} d } } a : e", "√ { a { b { c { c1 c2 } d } e } }")
        err += test("a { b { c d } } a { e }", "√ { a { b { c d } e } }")
        err += test("a { b { c {c1 c2} d } b.c : c3 }","√ { a { b { c { c1 c2 c3 } d } } }")
        err += test("a { b { c {c1 c2} d } b.c { c3 } }","√ { a { b { c { c1 c2 c3 } d } } }")
        err += test("a { b { c {c1 c2} d } b.c { c2:2 c3 } }","√ { a { b { c { c1 c2:2 c3 } d } } }")
        err += test("a { b { c d } b.e }","√ { a { b { c d e } } }")
        err += test("a { b { c d } b.e.f }","√ { a { b { c d e { f } } } }")

        err += test("a { b { c {c1 c2} d {d1 d2} } b.c : b.d  }", "√ { a { b { c { c1 c2 d1 d2 } d { d1 d2 } } } }")
        err += test("a { b { c d } } a : e", "√ { a { b { c d } e } }")
        err += test("ab { a:1 b:2 } cd:ab { a:3 c:4 d:5 } ef:cd { b:6 d:7 e:8 f:9 }",
                    "√ { ab { a:1 b:2 } cd { a:3 b:2 c:4 d:5 } ef { a:3 b:6 c:4 d:7 e:8 f:9 } }")

        err += test("ab { a:1 b:2 } ab:{ c:4 d:5 }","√ { ab { a:1 b:2 c:4 d:5 } }")

        err += test("ab { a:1 b:2 } cd { c:4 d:5 } ab˚.:cd",
                    "√ { ab { a:1 { c:4 d:5 } b:2 { c:4 d:5 } } cd { c:4 d:5 } }")

        err += test("a.b { _c { c1 c2 } c:_c { d e } }","√ { a { b { _c { c1 c2 } c { c1 c2 d e } } } }")
        err += test("a.b { _c { c1 c2 } c { d e }:_c }","√ { a { b { _c { c1 c2 } c { d e c1 c2 } } } }")

        err += test("a.b.c.d { e.f }", "√ { a { b { c { d { e { f } } } } } }")
        XCTAssertEqual(err,0)
    }
    func testParseEdges() { print("\n━━━━━━━━━━━━━━━━━━━━━━ edges ━━━━━━━━━━━━━━━━━━━━━━\n")
        var err = 0
        err += test("a b c <- b", "√ { a b c<-b }")
        err += test("a b c -> b", "√ { a b c->b }")
        err += test("a { a1 a2 } w <- a.* ", "√ { a { a1 a2 } w<-(a.a1 a.a2) }")
        err += test("a { b { c } } a <-> .* ", "√ { a<->a.b { b { c } } }")
        err += test("a { b { c } } a.b <-> c ", "√ { a { b<->a.b.c { c } } } ")
        err += test("a { b { c } } a˚˚ <-> .* ", "√ { a<->a.b { b<->a.b.c { c } } a˚˚ <-> .* }")
        err += test("a { b { c } } ˚˚ <-> .. ", "√ { a<->√ { b<->a { c<->a.b } } ˚˚ <-> .. }")

        print("\n━━━━━━━━━━━━━━━━━━━ multi edge ━━━━━━━━━━━━━━━━━━━━\n")

        err += test("a <- (b c)", "√ { a <-(b c) }")
        err += test("a <- (b c) { b c }", "√ { a <-(a.b a.c) { b c } }")
        err += test("a -> (b c) { b c }", "√ { a ->(a.b a.c) { b c } }")

        XCTAssertEqual(err,0)
    }
    func testParseTernarys() { print("\n━━━━━━━━━━━━━━ ternarys ━━━━━━━━━━━━━━━━━\n")
        var err = 0
        err += test("a x y w <-(a ? x : y)", "√ { a?>w x╌>w y╌>w w<-(a ? x : y) }")
        err += test("a x y w ->(a ? x : y)", "√ { a?>w x<╌w y<╌w w->(a ? x : y) }")
        err += test("a:1 x y w <-(a ? x : y)", "√ { a:1?>w x->w y╌>w w<-(a ? x : y) }")
        err += test("a:1 x y w ->(a ? x : y)", "√ { a:1?>w x<-w y<╌w w->(a ? x : y) }")
        err += test("a:0 x y w <-(a ? x : y)", "√ { a:0?>w x╌>w y╌>w w<-(a ? x : y) }")
        err += test("a:0 x y w ->(a ? x : y)", "√ { a:0?>w x<╌w y<╌w w->(a ? x : y) }")

        err += test("a x y w <->(a ? x : y)", "√ { a?>w x<╌>w y<╌>w w<->(a ? x : y) }")

        err += test("a b x y w <- (a ? x : b ? y)", "√ { a?>w b?>w x╌>w y╌>w w<-(a ? x : b ? y) }")
        err += test("a b c w <-(a ? 1 : b ? 2 : c ? 3)", "√ { a?>w b?>w c?>w w<-(a ? 1 : b ? 2 : c ? 3) }")
        err += test("a b c x <-(a ? b ? c ? 3 : 2 : 1)", "√ { a?>x b?>x c?>x x<-(a ? b ? c ? 3 : 2 : 1) }")
        err += test("a b c y <-(a ? (b ? (c ? 3) : 2) : 1)", "√ { a?>y b?>y c?>y y<-(a ? b ? c ? 3 : 2 : 1) }")
        err += test("a b c z <-(a ? 1) <-(b ? 2) <-(c ? 3)", "√ { a?>z b?>z c?>z z<-(a ? 1) <-(b ? 2) <-(c ? 3) }")
        err += test("a b w <-(a ? 1 : b ? 2 : 3)", "√ { a?>w b?>w w<-(a ? 1 : b ? 2 : 3) }"  )
        err += test("a b w <->(a ? 1 : b ? 2 : 3)", "√ { a?>w b?>w w<->(a ? 1 : b ? 2 : 3) }"  )

        print("\n━━━━━━━━━━━━━━━━━━━━━━ ternary conditionals ━━━━━━━━━━━━━━━━━━━━━━\n")

        err += test("a1 b1 a2 b2 w <- (a1 == a2 ? 1 : b1 == b2 ? 2 : 3)",
                    "√{ a1?>w b1?>w a2?>w b2?>w w<-(a1 == a2 ? 1 : b1 == b2 ? 2 : 3 ) }")

        err += test("d {a1 a2}:{b1 b2}:{c1 c2} h <- (d.a1 ? b1 ? c1 : 1)",
                    "√ { d { a1?>h { b1?>h { c1╌>h c2 } b2 { c1 c2 } } a2 { b1 { c1 c2 } b2 { c1 c2 } } } h<-(d.a1 ? b1 ? c1 : 1) }")

        print("\n━━━━━━━━━━━━━━━━━━━━━━ ternary paths ━━━━━━━━━━━━━━━━━━━━━━\n")

        err += test("a {b c}:{d e}:{f g} a <- a˚d.g",
                    "√ { a<-(b.d.g c.d.g) { b { d { f g } e { f g } } c { d { f g } e { f g } } } }")

        err += test("a {b c}:{d e}:{f g}:{i j} a.b˚f <- (f.i == f.j ? 1 : 0) ",
                    "√ { a { b { d { f<-(f.i == f.j ? 1 : 0 ) { i?>b.d.f j?>b.d.f } g { i j } }" +
                        "         e { f<-(f.i == f.j ? 1 : 0 ) { i?>b.e.f j?>b.e.f } g { i j } } }" +
                        "     c { d { f { i j } g { i j } }" +
                        "         e { f { i j } g { i j } } } } a.b˚f<-(f.i == f.j ? 1 : 0) }" +
            "")

        err += test("a {b c}:{d e}:{f g}:{i j} a.b˚f <- (f.i ? f.j : 0) ",
                    "√ { a { b { d { f<-(f.i ? f.j : 0 ) { i?>b.d.f j->b.d.f } g { i j } }" +
                        "         e { f<-(f.i ? f.j : 0 ) { i?>b.e.f j->b.e.f } g { i j } } }" +
                        "     c { d { f { i j } g { i j } }" +
                        "         e { f { i j } g { i j } } } } a.b˚f<-(f.i ? f.j : 0 ) }" +
            "")

        print("\n━━━━━━━━━━━━━━━━━━━━━━ ternary radio ━━━━━━━━━━━━━━━━━━━━━━\n")

        err += test("a b c x y z w <- (a ? 1 | b ? 2 | c ? 3)",
                    "√ { a?>w b?>w c?>w x y z w<-(a ? 1 | b ? 2 | c ? 3 ) } ")
        err += test("a b c x y z w <- (a ? x | b ? y | c ? z)",
                    "√ { a?>w b?>w c?>w x╌>w y╌>w z╌>w w<-(a ? x | b ? y | c ? z) }")
        err += test("a b c x y z w <-> (a ? x | b ? y | c ? z)",
                    "√ { a?>w b?>w c?>w x<╌>w y<╌>w z<╌>w w<->(a ? x | b ? y | c ? z) }")

        err += test("a {b c}:{d e}:{f g}:{i j} a.b˚f <- (f.i ? 1 | a˚j ? 0) ",
                    "√ { a { b { d { f<-(f.i ? 1 | a˚j ? 0 ) { i?>b.d.f j?>(b.d.f b.e.f) } g { i j?>(b.d.f b.e.f) } } " +
                        "         e { f<-(f.i ? 1 | a˚j ? 0 ) { i?>b.e.f j?>(b.d.f b.e.f) } g { i j?>(b.d.f b.e.f) } } } " +
                        "     c { d { f { i j?>(b.d.f b.e.f) } g { i j?>(b.d.f b.e.f) } } " +
                        "         e { f { i j?>(b.d.f b.e.f) } g { i j?>(b.d.f b.e.f) } } } } a.b˚f<-(f.i ? 1 | a˚j ? 0 ) }" +
            "")
        XCTAssertEqual(err,0)
    }
    func testParseRelativePaths() { print("\n━━━━━━━━━━━━━━ relative paths ━━━━━━━━━━━━━━━━━\n")
        var err = 0
        err += test("d {a1 a2}:{b1 b2} e <- d˚b1", "√ { d { a1 { b1 b2 } a2 { b1 b2 } } e <- (d.a1.b1 d.a2.b1) }")
        err += test("d {a1 a2}:{b1 b2} e <- d˚˚", "√ { d { a1 { b1 b2 } a2 { b1 b2 } } e <- (d d.a1 d.a1.b1 d.a1.b2 d.a2 d.a2.b1 d.a2.b2)  }")
        err += test("d {a1 a2}:{b1 b2} e <- (d˚b1 ? d˚b2)", "√ { d { a1 { b1?>e b2╌>e } a2 { b1?>e b2╌>e } } e<-(d˚b1 ? d˚b2) }")
        err += test("d {a1 a2}:{b1 b2} e <- (d.a1 ? a1.* : d.a2 ? a2.*)", "√ { d { a1?>e { b1╌>e b2╌>e } a2?>e { b1╌>e b2╌>e } } e<-(d.a1 ? a1.* : d.a2 ? a2.*) }")
        err += test("d {a1 a2}:{b1 b2} e <- (d.a1 ? .*   : d.a2 ? .*)",   "√ { d { a1?>e { b1╌>e b2╌>e } a2?>e { b1╌>e b2╌>e } } e<-(d.a1 ? .* : d.a2 ? .*) }")
        err += test("d {a1 a2}:{b1 b2} e <- (d˚a1 ? a1˚. : d˚a2 ? a2˚.)", "√ { d { a1?>e { b1╌>e b2╌>e } a2?>e { b1╌>e b2╌>e } } e<-(d˚a1 ? a1˚. : d˚a2 ? a2˚.) }")

        err += test("d {a1 a2}:{b1 b2}:{c1 c2} e <- (d˚b1 ? b1˚. : d˚b2 ? b2˚.)",
                    "√ { d { a1 { b1?>e { c1╌>e c2╌>e } b2?>e { c1╌>e c2╌>e } } a2 { b1?>e { c1╌>e c2╌>e } b2?>e { c1╌>e c2╌>e } } } e<-(d˚b1 ? b1˚. : d˚b2 ? b2˚.) }")

        err += test("d {a1 a2}:{b1 b2}:{c1 c2} e <- (d˚b1 ? b1˚. | d˚b2 ? b2˚.)",
                    "√ { d { a1 { b1?>e { c1╌>e c2╌>e } b2?>e { c1╌>e c2╌>e } } a2 { b1?>e { c1╌>e c2╌>e } b2?>e { c1╌>e c2╌>e } } } e<-(d˚b1 ? b1˚. | d˚b2 ? b2˚.) }")

        err += test("d {a1 a2}:{b1 b2}:{c1 c2} h <- (d.a1 ? b1 ? c1 : 1)",
                    "√ { d { a1?>h { b1?>h { c1╌>h c2 } b2 { c1 c2 } } a2 { b1 { c1 c2 } b2 { c1 c2 } } } h<-(d.a1 ? b1 ? c1 : 1) }")

        err += test("d {a1 a2}:{b1 b2}:{c1 c2} " +
            "e <- (d˚b1 ? b1˚. : d˚b2 ? b2˚.) " +
            "f <- (d˚b1 ? b1˚. : b2˚.) " +
            "g <- (d˚b1 ? b1˚.) <-(d˚b2 ? b2˚.) " +
            "h <- (d.a1 ? b1 ? c1 : 1) " +
            "i <- (d˚b1 ? b1˚. | d˚b2 ? b2˚.)",

                    "√ { d { " +
                        "a1?>h { b1?>(e f g h i) { c1╌>(e f g h i) c2╌>(e f g i) } b2?>(e g i) { c1╌>(e f g i) c2╌>(e f g i) } } " +
                        "a2   { b1?>(e f g i)   { c1╌>(e f g i)   c2╌>(e f g i) } b2?>(e g i) { c1╌>(e f g i) c2╌>(e f g i) } } } " +
                        "e<-(d˚b1 ? b1˚. : d˚b2 ? b2˚.) " +
                        "f<-(d˚b1 ? b1˚. : b2˚.) " +
                        "g<-(d˚b1 ? b1˚.) <-(d˚b2 ? b2˚.) " +
                        "h<-(d.a1 ? b1 ? c1 : 1) " +
                        "i<-(d˚b1 ? b1˚. | d˚b2 ? b2˚.) }" +
            "")

        err += test("d {a1 a2}:{b1 b2}:{c1 c2} e <- (d˚b1 ? b1˚. : d˚b2 ? b2˚.) ",
                    "√ { d { " +
                        "a1 { b1?>e { c1╌>e c2╌>e } b2?>e { c1╌>e c2╌>e } } " +
                        "a2 { b1?>e { c1╌>e c2╌>e } b2?>e { c1╌>e c2╌>e } } } " +
                        "e<-(d˚b1 ? b1˚. : d˚b2 ? b2˚.) }" +
            "")

        err += test("w {a b}:{c d}:{e f}:{g h} x <- (w˚c ? c˚. : w˚d ? d˚.) ",
                    "√ { w { " +
                        "a { c?>x { e { g╌>x h╌>x } f { g╌>x h╌>x } } d?>x { e { g╌>x h╌>x } f { g╌>x h╌>x } } } " +
                        "b { c?>x { e { g╌>x h╌>x } f { g╌>x h╌>x } } d?>x { e { g╌>x h╌>x } f { g╌>x h╌>x } } } } " +
                        "x<-(w˚c ? c˚. : w˚d ? d˚.) }" +
            "")
        XCTAssertEqual(err,0)
    }
    func testParseAvatarRobot() { print("\n━━━━━━━━━━━━━━ avatar robot ━━━━━━━━━━━━━━━━━\n")

        var err = 0

        err += test (
            """
avatar {left right}:{shoulder.elbow.wrist {thumb index middle ring pinky}:{meta prox dist} hip.knee.ankle.toes}
˚˚:{ pos:(x y z r s t) }
""","""
√ { avatar {
    left {
        shoulder {
            elbow {
                wrist {
                    thumb  { meta { pos:(x y z r s t) } prox { pos:(x y z r s t) } dist { pos:(x y z r s t) } pos:(x y z r s t) }
                    index  { meta { pos:(x y z r s t) } prox { pos:(x y z r s t) } dist { pos:(x y z r s t) } pos:(x y z r s t) }
                    middle { meta { pos:(x y z r s t) } prox { pos:(x y z r s t) } dist { pos:(x y z r s t) } pos:(x y z r s t) }
                    ring   { meta { pos:(x y z r s t) } prox { pos:(x y z r s t) } dist { pos:(x y z r s t) } pos:(x y z r s t) }
                    pinky  { meta { pos:(x y z r s t) } prox { pos:(x y z r s t) } dist { pos:(x y z r s t) } pos:(x y z r s t) }
                    pos:(x y z r s t) } pos:(x y z r s t) }
            pos:(x y z r s t) }
        hip {
            knee {
                ankle {
                    toes { pos:(x y z r s t) }
                    pos:(x y z r s t) }
                pos:(x y z r s t) }
            pos:(x y z r s t) }
        pos:(x y z r s t) }
    right {
        shoulder {
            elbow {
                wrist {
                    thumb  { meta { pos:(x y z r s t) } prox { pos:(x y z r s t) } dist { pos:(x y z r s t) } pos:(x y z r s t) }
                    index  { meta { pos:(x y z r s t) } prox { pos:(x y z r s t) } dist { pos:(x y z r s t) } pos:(x y z r s t) }
                    middle { meta { pos:(x y z r s t) } prox { pos:(x y z r s t) } dist { pos:(x y z r s t) } pos:(x y z r s t) }
                    ring   { meta { pos:(x y z r s t) } prox { pos:(x y z r s t) } dist { pos:(x y z r s t) } pos:(x y z r s t) }
                    pinky  { meta { pos:(x y z r s t) } prox { pos:(x y z r s t) } dist { pos:(x y z r s t) } pos:(x y z r s t) }
                    pos:(x y z r s t) } pos:(x y z r s t) } pos:(x y z r s t) }
        hip {
            knee {
                ankle {
                    toes { pos:(x y z r s t) }
                    pos:(x y z r s t) }
                pos:(x y z r s t) }
            pos:(x y z r s t) }
        pos:(x y z r s t) }
    pos:(x y z r s t) } }
""")


        err += test(
"""
robot {left right}:{shoulder.elbow.wrist {thumb index middle ring pinky}:{meta prox dist} hip.knee.ankle.toes}
˚˚ <-> ..
˚˚:{pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000)})
""","""
√ { robot<->√ {
left<->robot {
    shoulder<->robot.left {
        elbow<->robot.left.shoulder {
            wrist<->left.shoulder.elbow {
                thumb<->shoulder.elbow.wrist {
                    meta<->elbow.wrist.thumb { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    prox<->elbow.wrist.thumb { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    dist<->elbow.wrist.thumb { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                index<->shoulder.elbow.wrist {
                    meta<->elbow.wrist.index { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    prox<->elbow.wrist.index { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    dist<->elbow.wrist.index { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                middle<->shoulder.elbow.wrist {
                    meta<->elbow.wrist.middle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    prox<->elbow.wrist.middle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    dist<->elbow.wrist.middle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                ring<->shoulder.elbow.wrist {
                    meta<->elbow.wrist.ring { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    prox<->elbow.wrist.ring { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    dist<->elbow.wrist.ring { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                pinky<->shoulder.elbow.wrist {
                    meta<->elbow.wrist.pinky { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    prox<->elbow.wrist.pinky { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    dist<->elbow.wrist.pinky { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
            pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
    hip<->robot.left {
        knee<->robot.left.hip {
            ankle<->left.hip.knee {
                toes<->hip.knee.ankle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
            pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
right<->robot {
    shoulder<->robot.right {
        elbow<->robot.right.shoulder {
            wrist<->right.shoulder.elbow {
                thumb<->shoulder.elbow.wrist {
                    meta<->elbow.wrist.thumb { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    prox<->elbow.wrist.thumb { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    dist<->elbow.wrist.thumb { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                index<->shoulder.elbow.wrist {
                    meta<->elbow.wrist.index { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    prox<->elbow.wrist.index { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    dist<->elbow.wrist.index { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                middle<->shoulder.elbow.wrist {
                    meta<->elbow.wrist.middle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    prox<->elbow.wrist.middle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    dist<->elbow.wrist.middle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                ring<->shoulder.elbow.wrist {
                    meta<->elbow.wrist.ring { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    prox<->elbow.wrist.ring { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    dist<->elbow.wrist.ring { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                pinky<->shoulder.elbow.wrist {
                    meta<->elbow.wrist.pinky { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    prox<->elbow.wrist.pinky { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    dist<->elbow.wrist.pinky { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
            pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
    hip<->robot.right {
        knee<->robot.right.hip {
            ankle<->right.hip.knee {
                toes<->hip.knee.ankle { pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
                pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
            pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
        pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
    pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000) }
˚˚<->.. }
""")
        //Tr3Log.dump()
        XCTAssertEqual(err,0)
    }

    var result = ""
    
    /// add result of callback to result
    func addCallResult(_ tr3:Tr3, _ val:Tr3Val?) {
        var val = val?.printVal() ?? "nil"
        if val.first == " " { val.removeFirst() }
        result += tr3.name + ":" + val + " "
    }
    /// setup new result string, call the action, print the appeneded result
    func testAct(_ before:String,_ after:String, callTest: @escaping CallVoid) -> Int {
        var err = 0
        result = before + " ⟹ "
        let expected = result + after
        callTest()

        if let error = ParStr.compare(expected, result) {
            print (result + "🚫 mismatch \n\(error)")
            err += 1
        }
        else {
            print (result + "✓")
        }
        return err
    }
    func testEdgeVal() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a:1 b->a:2"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            //let a =  root.findPath("a"),
            let b =  root.findPath("b") {

            b.activate()
            let result =  root.dumpScript(session:true)
            err = ParStr.testCompare("√ { a:2 b->a:2 }", result)
        }
        else {
            err = 1
        }
        XCTAssertEqual(err,0)
    }
    func testEdgeVal2() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a {a1 a2} b->a.*:2"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            //let a =  root.findPath("a"),
            let b =  root.findPath("b") {

            b.activate()
            let result =  root.dumpScript(session:true)
            err = ParStr.testCompare("√ { a { a1:2 a2:2 } b->(a.a1:2 a.a2:2) }", result)
        }
        else {
            err = 1
        }

        XCTAssertEqual(err,0)
    }
    func testEdgeVal3() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a:{b c}:{f g} z->(a˚g:2)"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            //let a =  root.findPath("a"),
            let z =  root.findPath("z") {

            z.activate()
            let result =  root.dumpScript(session:true)
            err += ParStr.testCompare("√ { a { b { f g:2 } c { f g:2 } } z->(a.b.g:2 a.c.g:2) }", result)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err,0)
    }
    func testEdgeVal4() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a:{b c}:{f g} z->(a.b.f:1 a˚g:2)"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            //let a =  root.findPath("a"),
            let z =  root.findPath("z") {

            z.activate()
            let result =  root.dumpScript(session:false)
            err += ParStr.testCompare("√ { a { b { f:1 g:2 } c { f g:2 } } z->(a.b.f:1 a.b.g:2 a.c.g:2) }", result)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err,0)
    }
    func testTuple1() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a:(x:0)<-c b:(y:0) <-c c:(x:0 y:0)"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            let c = root.findPath("c") {
            c.setVal(CGPoint(x:1,y:2), .activate)
            let result =  root.dumpScript(session:true)
            err = ParStr.testCompare("√ { a:(1)<-c b:(2)<-c c:(1 2) }", result, echo:true)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err,0)
    }
    func testTuple2() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

        Par.trace = true
        Par.trace2 = true
        var err = 0

        let script = "a:(x y):(0...1=0)"
        print("\n" + script)

        let p0 = CGPoint(x:1, y:1)
        var p1 = CGPoint.zero

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a") {

            a.addClosure { tr3,_ in
                p1 = tr3.CGPointVal() ?? .zero
                print("p0:\(p0) => p1:\(p1)")
            }

            a.setVal(p0, [.activate])

            let result0 =  root.dumpScript(session:true)
            err += ParStr.testCompare("√ { a:(1 1) }", result0, echo:true)
            let result1 =  root.dumpScript(session:false)
            err += ParStr.testCompare("√ { a:(x y):(0...1=0) }", result1, echo:true)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err,0)
        XCTAssertEqual(p0,p1)
        Par.trace = false
        Par.trace2 = false
    }
    func testPassthrough() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
        var err = 0
        let script = "a:(0...1=0)<-b b<-c c:(0...10)<-a"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let b = root.findPath("b"),
            let c = root.findPath("c") {

            a.addClosure { tr3,_ in
                self.addCallResult(a,tr3.val!) }
            b.addClosure { tr3,_ in
                self.addCallResult(b,tr3.val!) }
            c.addClosure { tr3,_ in
                self.addCallResult(c,tr3.val!) }

            err += testAct("c:5.0","c:5.0 b:5.0 a:0.5") {
                c.setVal(5.0, .activate) }
            err += testAct("a:0.1","a:0.1 c:1.0 b:1.0 ") {
                a.setVal(0.1, .activate) }
            err += testAct("b:0.2","b:0.2 a:0.020000001 c:0.20000002") {
                b.setVal(0.2, .activate) }
        }
        else {
            err += 1
        }
        XCTAssertEqual(err,0)
    }

    func testTernary1() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
        var err  = 0
        let script = "a b c w:0 <- (a ? 1 : b ? 2 : c ? 3)"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let b = root.findPath("b"),
            let c = root.findPath("c"),
            let w = root.findPath("w") {

            err += ParStr.testCompare("√ { a?>w b?>w c?>w w:0<-(a ? 1 : b ? 2 : c ? 3) }", root.dumpScript(session:true), echo:true)

            w.addClosure { tr3,_ in self.addCallResult(w,tr3.val!) }
            err += testAct("a!", "w:1.0 ") { a.activate() }
            err += testAct("a:0","w:1.0")  { a.setVal(0,[.create,.activate]) }
            err += testAct("b!", "w:2.0 ") { b.activate() }
            err += testAct("b:0","w:2.0")  { b.setVal(0,[.create,.activate]) }
            err += testAct("c!", "w:3.0 ") { c.activate() }

            err += ParStr.testCompare(" √ { a:0?>w b:0?>w c?>w w:3<-(a ? 1 : b ? 2 : c ? 3) }", root.dumpScript(session:true), echo:true)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err,0)
    }
    func testTernary2() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
        var err = 0
        let script = "a:0 x:10 y:20 w <- (a ? x : y)"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let x = root.findPath("x"),
            let y = root.findPath("y"),
            let w = root.findPath("w") {

            err += ParStr.testCompare("√ { a:0?>w x:10╌>w y:20╌>w w<-(a ? x : y) }", root.dumpScript(session:true), echo:true)

            w.addClosure { tr3,_ in self.addCallResult(w,tr3.val!) }
            err += testAct("a:0","w:20.0")  { a.setVal(0,.activate) }
            err += testAct("x:11","")       { x.setVal(11,.activate) }
            err += testAct("y:21","w:21.0") { y.setVal(21,.activate) }

            err += testAct("a:1","w:11.0")  { a.setVal(1,.activate) }
            err += testAct("x:12","w:12.0") { x.setVal(12,.activate) }
            err += testAct("y:22","")       { y.setVal(22,.activate) }

            err += testAct("a:0","w:22.0")  { a.setVal(0,.activate) }

            err += ParStr.testCompare("√ { a:0?>w x:12╌>w y:22->w w:y<-(a ? x : y) }", root.dumpScript(session:true), echo:true)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err,0)
    }
    func testTernary3() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
        var err = 0
        let script = "a x:10 y:20 w <-> (a ? x : y)"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let x = root.findPath("x"),
            let y = root.findPath("y"),
            let w = root.findPath("w") {

            err += ParStr.testCompare("√ { a?>w x:10<╌>w y:20<╌>w w<->(a ? x : y) }", root.dumpScript(session:true), echo:true)

            w.addClosure { tr3,_ in self.addCallResult(w,tr3.val!) }
            x.addClosure { tr3,_ in self.addCallResult(x,tr3.val!) }
            y.addClosure { tr3,_ in self.addCallResult(y,tr3.val!) }
            err += testAct("a:0","w:20.0 y:20.0") { a.setVal(0,[.create,.activate]) }
            err += testAct("w:3","w:3.0 y:3.0")   { w.setVal(3,[.create,.activate]) }
            err += testAct("a:1","w:3.0 x:3.0")   { a.setVal(1,.activate) }
            err += testAct("w:4","w:4.0 x:4.0")   { w.setVal(4,[.activate]) }

            err += ParStr.testCompare("√ { a:1?>w x:4<->w y:3<╌>w w:4<->(a ? x : y) }", root.dumpScript(session:true), echo:true)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err,0)
    }
    func testEdges() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
        var err = 0
        let root = Tr3("√")
        //let script = "x.xx y.yy a.b c:a { d <- (x ? x.xx | y ? y.yy) } e:c f:e g:f"
        //let script = "x.xx y.yy a.b c:a e:c f:e g:f ˚b <- (x ? x.xx | y ? y.yy) "
        //let script = "x.xx y.yy a { b <- (x ? x.xx | y ? y.yy) } c:a e:c f:e g:f "
        let script = "a.b.c:1 d { e:2<->a.b.c } f:d"

        if tr3Parse.parseScript(root,script, whitespace: "\n\t ") {

            let pretty = root.makeScript(0,pretty:true)
            print(pretty)

            let d3Script = root.makeD3Script()
            print(d3Script)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err,0)
    }
    func testSky() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
    
        var err = 0
        let root = Tr3("√")
        let tr3Parse = Tr3Parse()

        func parse(_ name:String, _ script:String) -> Int {
            let success = tr3Parse.parseScript(root, script, whitespace: "\n\t ")
            if success  { print("\(name) ✓") }
            else        { print("\(name) 🚫 parse failed") }
            return success ? 0 : 1
        }

        err += parse("SkyMainTr3",SkyMainTr3)
        err += parse("SkyShaderTr3",SkyShaderTr3)
        err += parse("PanelCellTr3",PanelCellTr3)
        err += parse("PanelCellFaderTr3",PanelCellFaderTr3)
        err += parse("PanelCellFredkinTr3",PanelCellFredkinTr3)
        err += parse("PanelCellTimeTunnelTr3",PanelCellTimeTunnelTr3)
        err += parse("PanelCellZhabatinskiTr3",PanelCellZhabatinskiTr3)
        err += parse("PanelCellMeltTr3",PanelCellMeltTr3)
        err += parse("PanelCellAverageTr3",PanelCellAverageTr3)
        err += parse("PanelCellSlideTr3",PanelCellSlideTr3)
        err += parse("PanelCellBrushTr3",PanelCellBrushTr3)
        err += parse("PanelShaderColorizeTr3",PanelShaderColorizeTr3)
        err += parse("PanelCellScrollTr3",PanelCellScrollTr3)
        err += parse("PanelShaderTileTr3",PanelShaderTileTr3)
        err += parse("PanelSpeedTr3",PanelSpeedTr3)

        let actual = root.makeScript(0,pretty:false)
        err += ParStr.testCompare(SkyOutput,actual)

        XCTAssertEqual(err,0)
    }


    static var allTests = [

        ("testParseShort",testParseShort),
        ("testParseBasics",testParseBasics),
        ("testParseSkyControl",testParseSkyControl),
        ("testParsePathProto",testParsePathProto),
        ("testParsePaths",testParsePaths),
        ("testParseValues",testParseValues),
        ("testParseEdges",testParseEdges),
        ("testParseTernarys",testParseTernarys),
        ("testParseRelativePaths",testParseRelativePaths),
        ("testParseRelativePaths",testParseRelativePaths),
        ("testParseAvatarRobot",testParseAvatarRobot),

        ("testEdgeVal",testEdgeVal),
        ("testEdgeVal2",testEdgeVal2),
        ("testEdgeVal3",testEdgeVal3),
        ("testEdgeVal4",testEdgeVal3),
        ("testTuple1",testTuple1),
        ("testTuple2",testTuple2),
        ("testPassthrough",testPassthrough),
        ("testTernary1",testTernary1),
        ("testTernary2",testTernary2),
        ("testTernary3",testTernary3),
        ("testEdges",testEdges),
        ("testSky",testSky),
    ]
}
