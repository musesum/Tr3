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

    var countTotal = 0
    var countError = 0
    var tr3Parse = Tr3Parse()


    /// compare expected with actual result and print error strings
    /// with 🚫 marker at beginning of non-matching section
    ///
    /// - parameter script: expected output
    /// - parameter script: actual output
    ///
    func testCompare(_ expected:String, _ actual:String, echo:Bool = false) {
        if echo {
            print ("⟹ " + expected, terminator:"")
        }
        // for non-match, compare will insert a 🚫 into expectedErr and actualErr
        if let (expectedErr,actualErr) = ParStr.compare(expected, actual) {
            print (" 🚫 mismatch")
            print ("⟹ " + expectedErr)
            print ("⟹ " + actualErr + "\n")
            countError += 1
        }
        else {
            print ("⟹ " + expected + " ✓\n")
        }
    }

    /// Test script produces expected output
    /// - parameter script: test script
    /// - parameter expected: exected output after parse
    ///
    func test(_ script:String,_ expected:String,session:Bool = false) {

        print(script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root,script, whitespace: "\n\t ") {

            let actual = root.dumpScript(session:session)
            testCompare(expected,actual)
        }
        else  {
            print(" 🚫 failed parse")
            countError += 1
        }
        countTotal += 1
    }
    func testParseShort() {

        countTotal = 0
        Tr3.dumpScript = true

        test("a {b c}:{d e}:{f g}:{h i} z -> a.b˚g.h",
             "√ { a { b { d { f { h i } g { h i } } e { f { h i } g { h i } } } " +
            "         c { d { f { h i } g { h i } } e { f { h i } g { h i } } } } " +
            " z->(d.g.h e.g.h) }")

        Tr3.debugName = "g.h"
        Tr3.dumpScript = false

        test("a b c a<-b a<-c","√ { a<-(b c) b c }")

        test("a {b c}:{d e f -> b:1} z:a z.b.f => c:1 ",
             "√ { a { b { d e f->a.b:1 } c { d e f->a.b:1 } }" +
            "     z { b { d e f=>z.c:1 } c { d e f->z.b:1 } } }")

         test("a._c { d { e { f : \"ff\" } } } a.c.z : _c { d { e.f   : \"ZZ\" } }",
        "√ { a { _c { d { e { f:\"ff\" } } } c { z { d { e { f:\"ZZ\" } } } } } }")

        test("a.b { _c { d e.f:(0...1=0) g} z:_c { g } } ",
             "√ { a { b { _c { d e { f:(0...1=0) } g } z { d e { f:(0...1=0) } g } } } }")

        test("a.b._c {d:1} a.b.e:_c","√ { a { b { _c { d:1 } e { d:1 } } } }")

        test("a {b c}:{d e}:{f g}:{i j} a.b˚f <- (f.i ? f.j : 0) ",
         "√ { a { b { d { f<-(f.i ? f.j : 0 ) { i?>b.d.f j->b.d.f } g { i j } }" +
            "         e { f<-(f.i ? f.j : 0 ) { i?>b.e.f j->b.e.f } g { i j } } }" +
            "     c { d { f { i j } g { i j } }" +
            "         e { f { i j } g { i j } } } } a.b˚f<-(f.i ? f.j : 0 ) }" +
        "")

        test("a {b c}:{d <-(b ? 1 | c ? 2) e } z:a z.b.d <- (b ? 5 | c ? 6)",
             "√ { a { b?>(a.b.d a.c.d) { d<-(b ? 1 | c ? 2) e } " +
                "     c?>(a.b.d a.c.d) { d<-(b ? 1 | c ? 2) e } } " +
                " z { b?>(z.b.d z.c.d) { d<-(b ? 5 | c ? 6) e } " +
                "     c?>(z.b.d z.c.d) { d<-(b ? 1 | c ? 2) e } } }" +
            "")


        test("a b->a:1", "√ { a b->a:1 }")

        test("a <- (b c)", "√ { a <-(b c) }")

        test("a b.c <-(a ? 1) d:b ",
             "√ { a?>(b.c d.c) b { c<-(a ? 1 ) } d { c<-(a ? 1 ) } }")

        test("a {b <-(a ? 1) c} ",
             "√ { a?>a.b { b<-(a ? 1 ) c } }")

        test("a {b c}:{d <-(b ? 1 | c ? 2) e} ",
             "√ { a { b?>(a.b.d a.c.d) { d<-(b ? 1 | c ? 2) e } " +
            "         c?>(a.b.d a.c.d) { d<-(b ? 1 | c ? 2) e } } }")

        test("a b c w <-(a ? 1 : b ? 2 : c ? 3)",
             "√ { a?>w b?>w c?>w w<-(a ? 1 : b ? 2 : c ? 3) }")

        test("a.b { c d } a.e:a.b { f g } ", "√ { a { b { c d } e { c d f g } } }")

        test("a { b c } d:a { e f } g:d { h i } j:g { k l }",
             "√ { a { b c } d { b c e f } g { b c e f h i } j { b c e f h i k l } }")

        test("a { b c }    h:a { i j }","√ { a { b c } h { b c i j } }")
        test("a { b c } \n h:a { i j }","√ { a { b c } h { b c i j } }")

        XCTAssertEqual(countError,0)
    }
    /// compare script with expected output and print an error if they don't match
    func testParseBasics() {
        countError = 0
        print("\n━━━━━━━━━━━━━━━━━━━━━━ quote ━━━━━━━━━━━━━━━━━━━━━━\n")
        test("a:\"yo\"", "√ { a:\"yo\" }")
        test("a { b:\"bb\" }", "√ { a { b:\"bb\" } }")
        test("a { b:\"bb\" c:\"cc\" }", "√ { a { b:\"bb\" c:\"cc\" } }")

        print("\n━━━━━━━━━━━━━━━━━━━━━ comment ━━━━━━━━━━━━━━━━━━━━━\n")
        test("a // yo","√ { a }")
        test("a { b } // yo","√ { a { b } }")
        test("a { b // yo \n } ", "√ { a { b } }")
        test("a { b { // yo \n c } } ", "√ { a { b { c } } }")
        test("// yo \na { b { c } }","√ { a { b { c } } }")
        test("// yo\n// oy\na { b { c } }","√ { a { b { c } } }")

        print("\n━━━━━━━━━━━━━━━━━━━━━━ hierarchy ━━━━━━━━━━━━━━━━━━━━━━\n")
        test("a { b c }","√ { a { b c } }")
        test("a { b { c } }","√ { a { b { c } } }")
        test("a { b { c } d { e } }","√ { a { b { c } d { e } } }")
        test("a { b { c d } e }","√ { a { b { c d } e } }")

        print("\n━━━━━━━━━━━━━━━━━━━━━━ many ━━━━━━━━━━━━━━━━━━━━━━\n")
        test("a {b c}:{d e}","√ { a { b { d e } c { d e } } }")
        test("a {b c}:{d e}:{f g}","√ { a { b { d { f g } e { f g } } c { d { f g } e { f g } } } }")
        XCTAssertEqual(countError,0)
    }
    func testParseSkyControl() {
        countError = 0
        test("""
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

        XCTAssertEqual(countError,0)
    }
    func testParsePathProto() {
        countError = 0
        test("a.b.c { b { d } }", "√ { a { b { c { b { d } } } } }")
        test("a.b { c d } e:a { b.c:0 }", "√ { a { b { c d } } e { b { c:0 d } } }")
        test("a { b { c } } a.b <-> c ", "√ { a { b<->a.b.c { c } } } ")
        test("a { b { c d } } e { b { c d } b:0 }" , "√ { a { b { c d } } e { b:0 { c d } } }")

        test("a {b c}:{d e}:{f g}:{i j} a.b˚f <- (f.i ? f.j : 0) ",
             "√ { a { b { d { f<-(f.i ? f.j : 0 ) { i?>b.d.f j->b.d.f } g { i j } }" +
                "         e { f<-(f.i ? f.j : 0 ) { i?>b.e.f j->b.e.f } g { i j } } }" +
                "     c { d { f { i j } g { i j } }" +
                "         e { f { i j } g { i j } } } } a.b˚f<-(f.i ? f.j : 0 ) }" +
            "")

        XCTAssertEqual(countError,0)
    }
    func testParseValues() {
        countError = 0
        print("\n━━━━━━━━━━━━━━━━━━━━━━ tr3 scalars ━━━━━━━━━━━━━━━━━━━━━━\n")
        test("a { b:2 { c } }","√ { a { b:2 { c } } }")
        test("a:1 { b:2 { c:3 } }","√ { a:1 { b:2 { c:3 } } }")
        test("a: 0...1=0.5 { b:(1...2) { c:(2..<3) } }","√ { a:(0...1=0.5) { b:(1...2) { c:(2..<3) } } }")
        test("a:%2 b:(%2)","√ { a:(%2) b:(%2) }")

        print("\n━━━━━━━━━━━━━━━━━━━━━━ tr3 tuples ━━━━━━━━━━━━━━━━━━━━━━\n")
        test("a:(x y):(0...1=0.5)","√ { a:(x y):(0...1=0.5) }")
        test("a:(x y):(1...2)","√ { a:(x y):(1...2) }")
        test("b:(x y):(-1. 2.)","√ { b:(x y):(-1 2) }")
        test("c:(x:3 y:+4)","√ { c:(x:3 y:4) }")
        test("d:(x y z)","√ { d:(x y z) }")
        test("m:(0 0 0) n->m:(1 1 1)", "√ { m:(0 0 0) n->m:(1 1 1) }")
        test("m:(0 0 0) n:(1 1 1)->m", "√ { m:(0 0 0) n:(1 1 1)->m }")

        test("e:(x y):(-16...16=0)","√ { e:(x y):(-16...16=0) }")
        test("f:(p q r):(0...1=0)","√ { f:(p q r):(0...1=0) }")
        test("g:(p q r):(0...1=0):(.5 .5 .5)","√ { g:(p q r):(0.5 0.5 0.5):(0...1=0) }")
        test("h:(p:0.5 q:0.5 r:0.5):(0...1=0)","√ { h:(p:0.5 q:0.5 r:0.5):(0...1=0) }")
        test("i:(0.5 0.5 0.5):(0...1=0)","√ { i:(0.5 0.5 0.5):(0...1=0) }")
        XCTAssertEqual(countError,0)
    }
    func testParsePaths() { print("\n━━━━━━━━━━━━━━━━━━━━━━ paths ━━━━━━━━━━━━━━━━━━━━━━\n")
        countError = 0

        test("a { b { c {c1 c2} d } } a : e", "√ { a { b { c { c1 c2 } d } e } }")
        test("a { b { c d } } a { e }", "√ { a { b { c d } e } }")
        test("a { b { c {c1 c2} d } b.c : c3 }","√ { a { b { c { c1 c2 c3 } d } } }")
        test("a { b { c {c1 c2} d } b.c { c3 } }","√ { a { b { c { c1 c2 c3 } d } } }")
        test("a { b { c {c1 c2} d } b.c { c2:2 c3 } }","√ { a { b { c { c1 c2:2 c3 } d } } }")
        test("a { b { c d } b.e }","√ { a { b { c d e } } }")
        test("a { b { c d } b.e.f }","√ { a { b { c d e { f } } } }")

        test("a { b { c {c1 c2} d {d1 d2} } b.c : b.d  }", "√ { a { b { c { c1 c2 d1 d2 } d { d1 d2 } } } }")
        test("a { b { c d } } a : e", "√ { a { b { c d } e } }")
        test("ab { a:1 b:2 } cd:ab { a:3 c:4 d:5 } ef:cd { b:6 d:7 e:8 f:9 }",
             "√ { ab { a:1 b:2 } cd { a:3 b:2 c:4 d:5 } ef { a:3 b:6 c:4 d:7 e:8 f:9 } }")

        test("ab { a:1 b:2 } ab:{ c:4 d:5 }","√ { ab { a:1 b:2 c:4 d:5 } }")

        test("ab { a:1 b:2 } cd { c:4 d:5 } ab˚.:cd",
             "√ { ab { a:1 { c:4 d:5 } b:2 { c:4 d:5 } } cd { c:4 d:5 } }")

        test("a.b { _c { c1 c2 } c:_c { d e } }","√ { a { b { _c { c1 c2 } c { c1 c2 d e } } } }")
        test("a.b { _c { c1 c2 } c { d e }:_c }","√ { a { b { _c { c1 c2 } c { d e c1 c2 } } } }")

        test("a.b.c.d { e.f }", "√ { a { b { c { d { e { f } } } } } }")
        XCTAssertEqual(countError,0)
    }
    func testParseEdges() { print("\n━━━━━━━━━━━━━━━━━━━━━━ edges ━━━━━━━━━━━━━━━━━━━━━━\n")
        countError = 0
        test("a b c <- b", "√ { a b c<-b }")
        test("a b c -> b", "√ { a b c->b }")
        test("a { a1 a2 } w <- a.* ", "√ { a { a1 a2 } w<-(a.a1 a.a2) }")
        test("a { b { c } } a <-> .* ", "√ { a<->a.b { b { c } } }")
        test("a { b { c } } a.b <-> c ", "√ { a { b<->a.b.c { c } } } ")
        test("a { b { c } } a˚˚ <-> .* ", "√ { a<->a.b { b<->a.b.c { c } } a˚˚ <-> .* }")
        test("a { b { c } } ˚˚ <-> .. ", "√ { a<->√ { b<->a { c<->a.b } } ˚˚ <-> .. }")

        print("\n━━━━━━━━━━━━━━━━━━━ multi edge ━━━━━━━━━━━━━━━━━━━━\n")

        test("a <- (b c)", "√ { a <-(b c) }")
        test("a <- (b c) { b c }", "√ { a <-(a.b a.c) { b c } }")
        test("a -> (b c) { b c }", "√ { a ->(a.b a.c) { b c } }")
        XCTAssertEqual(countError,0)
    }
    func testParseTernarys() { print("\n━━━━━━━━━━━━━━ ternarys ━━━━━━━━━━━━━━━━━\n")
        countError = 0
        test("a x y w <-(a ? x : y)", "√ { a?>w x╌>w y╌>w w<-(a ? x : y) }")
        test("a x y w ->(a ? x : y)", "√ { a?>w x<╌w y<╌w w->(a ? x : y) }")
        test("a:1 x y w <-(a ? x : y)", "√ { a:1?>w x->w y╌>w w<-(a ? x : y) }")
        test("a:1 x y w ->(a ? x : y)", "√ { a:1?>w x<-w y<╌w w->(a ? x : y) }")
        test("a:0 x y w <-(a ? x : y)", "√ { a:0?>w x╌>w y╌>w w<-(a ? x : y) }")
        test("a:0 x y w ->(a ? x : y)", "√ { a:0?>w x<╌w y<╌w w->(a ? x : y) }")

        test("a x y w <->(a ? x : y)", "√ { a?>w x<╌>w y<╌>w w<->(a ? x : y) }")

        test("a b x y w <- (a ? x : b ? y)", "√ { a?>w b?>w x╌>w y╌>w w<-(a ? x : b ? y) }")
        test("a b c w <-(a ? 1 : b ? 2 : c ? 3)", "√ { a?>w b?>w c?>w w<-(a ? 1 : b ? 2 : c ? 3) }")
        test("a b c x <-(a ? b ? c ? 3 : 2 : 1)", "√ { a?>x b?>x c?>x x<-(a ? b ? c ? 3 : 2 : 1) }")
        test("a b c y <-(a ? (b ? (c ? 3) : 2) : 1)", "√ { a?>y b?>y c?>y y<-(a ? b ? c ? 3 : 2 : 1) }")
        test("a b c z <-(a ? 1) <-(b ? 2) <-(c ? 3)", "√ { a?>z b?>z c?>z z<-(a ? 1) <-(b ? 2) <-(c ? 3) }")
        test("a b w <-(a ? 1 : b ? 2 : 3)", "√ { a?>w b?>w w<-(a ? 1 : b ? 2 : 3) }"  )
        test("a b w <->(a ? 1 : b ? 2 : 3)", "√ { a?>w b?>w w<->(a ? 1 : b ? 2 : 3) }"  )

        print("\n━━━━━━━━━━━━━━━━━━━━━━ ternary conditionals ━━━━━━━━━━━━━━━━━━━━━━\n")

        test("a1 b1 a2 b2 w <- (a1 == a2 ? 1 : b1 == b2 ? 2 : 3)", "√{ a1?>w b1?>w a2?>w b2?>w w<-(a1 == a2 ? 1 : b1 == b2 ? 2 : 3 ) }")

        test("d {a1 a2}:{b1 b2}:{c1 c2} h <- (d.a1 ? b1 ? c1 : 1)",
             "√ { d { a1?>h { b1?>h { c1╌>h c2 } b2 { c1 c2 } } a2 { b1 { c1 c2 } b2 { c1 c2 } } } h<-(d.a1 ? b1 ? c1 : 1) }")

        print("\n━━━━━━━━━━━━━━━━━━━━━━ ternary paths ━━━━━━━━━━━━━━━━━━━━━━\n")

        test("a {b c}:{d e}:{f g} a <- a˚d.g",
             "√ { a<-(b.d.g c.d.g) { b { d { f g } e { f g } } c { d { f g } e { f g } } } }")

        test("a {b c}:{d e}:{f g}:{i j} a.b˚f <- (f.i == f.j ? 1 : 0) ",
             "√ { a { b { d { f<-(f.i == f.j ? 1 : 0 ) { i?>b.d.f j?>b.d.f } g { i j } }" +
                "         e { f<-(f.i == f.j ? 1 : 0 ) { i?>b.e.f j?>b.e.f } g { i j } } }" +
                "     c { d { f { i j } g { i j } }" +
                "         e { f { i j } g { i j } } } } a.b˚f<-(f.i == f.j ? 1 : 0) }" +
            "")

        test("a {b c}:{d e}:{f g}:{i j} a.b˚f <- (f.i ? f.j : 0) ",
             "√ { a { b { d { f<-(f.i ? f.j : 0 ) { i?>b.d.f j->b.d.f } g { i j } }" +
                "         e { f<-(f.i ? f.j : 0 ) { i?>b.e.f j->b.e.f } g { i j } } }" +
                "     c { d { f { i j } g { i j } }" +
                "         e { f { i j } g { i j } } } } a.b˚f<-(f.i ? f.j : 0 ) }" +
            "")

        print("\n━━━━━━━━━━━━━━━━━━━━━━ ternary radio ━━━━━━━━━━━━━━━━━━━━━━\n")

        test("a b c x y z w <- (a ? 1 | b ? 2 | c ? 3)", "√ { a?>w b?>w c?>w x y z w<-(a ? 1 | b ? 2 | c ? 3 ) } ")
        test("a b c x y z w <- (a ? x | b ? y | c ? z)", "√ { a?>w b?>w c?>w x╌>w y╌>w z╌>w w<-(a ? x | b ? y | c ? z) }")
        test("a b c x y z w <-> (a ? x | b ? y | c ? z)", "√ { a?>w b?>w c?>w x<╌>w y<╌>w z<╌>w w<->(a ? x | b ? y | c ? z) }")

        test("a {b c}:{d e}:{f g}:{i j} a.b˚f <- (f.i ? 1 | a˚j ? 0) ",
             "√ { a { b { d { f<-(f.i ? 1 | a˚j ? 0 ) { i?>b.d.f j?>(b.d.f b.e.f) } g { i j?>(b.d.f b.e.f) } } " +
                "         e { f<-(f.i ? 1 | a˚j ? 0 ) { i?>b.e.f j?>(b.d.f b.e.f) } g { i j?>(b.d.f b.e.f) } } } " +
                "     c { d { f { i j?>(b.d.f b.e.f) } g { i j?>(b.d.f b.e.f) } } " +
                "         e { f { i j?>(b.d.f b.e.f) } g { i j?>(b.d.f b.e.f) } } } } a.b˚f<-(f.i ? 1 | a˚j ? 0 ) }" +
            "")
        XCTAssertEqual(countError,0)
    }
    func testParseRelativePaths() { print("\n━━━━━━━━━━━━━━ relative paths ━━━━━━━━━━━━━━━━━\n")

        countError = 0

        test("d {a1 a2}:{b1 b2} e <- d˚b1", "√ { d { a1 { b1 b2 } a2 { b1 b2 } } e <- (d.a1.b1 d.a2.b1) }")
        test("d {a1 a2}:{b1 b2} e <- d˚˚", "√ { d { a1 { b1 b2 } a2 { b1 b2 } } e <- (d d.a1 d.a1.b1 d.a1.b2 d.a2 d.a2.b1 d.a2.b2)  }")
        test("d {a1 a2}:{b1 b2} e <- (d˚b1 ? d˚b2)", "√ { d { a1 { b1?>e b2╌>e } a2 { b1?>e b2╌>e } } e<-(d˚b1 ? d˚b2) }")
        test("d {a1 a2}:{b1 b2} e <- (d.a1 ? a1.* : d.a2 ? a2.*)", "√ { d { a1?>e { b1╌>e b2╌>e } a2?>e { b1╌>e b2╌>e } } e<-(d.a1 ? a1.* : d.a2 ? a2.*) }")
        test("d {a1 a2}:{b1 b2} e <- (d.a1 ? .*   : d.a2 ? .*)",   "√ { d { a1?>e { b1╌>e b2╌>e } a2?>e { b1╌>e b2╌>e } } e<-(d.a1 ? .* : d.a2 ? .*) }")
        test("d {a1 a2}:{b1 b2} e <- (d˚a1 ? a1˚. : d˚a2 ? a2˚.)", "√ { d { a1?>e { b1╌>e b2╌>e } a2?>e { b1╌>e b2╌>e } } e<-(d˚a1 ? a1˚. : d˚a2 ? a2˚.) }")

        test("d {a1 a2}:{b1 b2}:{c1 c2} e <- (d˚b1 ? b1˚. : d˚b2 ? b2˚.)",
             "√ { d { a1 { b1?>e { c1╌>e c2╌>e } b2?>e { c1╌>e c2╌>e } } a2 { b1?>e { c1╌>e c2╌>e } b2?>e { c1╌>e c2╌>e } } } e<-(d˚b1 ? b1˚. : d˚b2 ? b2˚.) }")

        test("d {a1 a2}:{b1 b2}:{c1 c2} e <- (d˚b1 ? b1˚. | d˚b2 ? b2˚.)",
             "√ { d { a1 { b1?>e { c1╌>e c2╌>e } b2?>e { c1╌>e c2╌>e } } a2 { b1?>e { c1╌>e c2╌>e } b2?>e { c1╌>e c2╌>e } } } e<-(d˚b1 ? b1˚. | d˚b2 ? b2˚.) }")

        test("d {a1 a2}:{b1 b2}:{c1 c2} h <- (d.a1 ? b1 ? c1 : 1)",
             "√ { d { a1?>h { b1?>h { c1╌>h c2 } b2 { c1 c2 } } a2 { b1 { c1 c2 } b2 { c1 c2 } } } h<-(d.a1 ? b1 ? c1 : 1) }")

        test("d {a1 a2}:{b1 b2}:{c1 c2} " +
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

        test("d {a1 a2}:{b1 b2}:{c1 c2} e <- (d˚b1 ? b1˚. : d˚b2 ? b2˚.) ",
             "√ { d { " +
                "a1 { b1?>e { c1╌>e c2╌>e } b2?>e { c1╌>e c2╌>e } } " +
                "a2 { b1?>e { c1╌>e c2╌>e } b2?>e { c1╌>e c2╌>e } } } " +
                "e<-(d˚b1 ? b1˚. : d˚b2 ? b2˚.) }" +
            "")

        test("w {a b}:{c d}:{e f}:{g h} x <- (w˚c ? c˚. : w˚d ? d˚.) ",
             "√ { w { " +
                "a { c?>x { e { g╌>x h╌>x } f { g╌>x h╌>x } } d?>x { e { g╌>x h╌>x } f { g╌>x h╌>x } } } " +
                "b { c?>x { e { g╌>x h╌>x } f { g╌>x h╌>x } } d?>x { e { g╌>x h╌>x } f { g╌>x h╌>x } } } } " +
                "x<-(w˚c ? c˚. : w˚d ? d˚.) }" +
            "")
        XCTAssertEqual(countError,0)
    }
    func testParseAvatarRobot() { print("\n━━━━━━━━━━━━━━ avatar robot ━━━━━━━━━━━━━━━━━\n")

        countError = 0

        test("avatar {left right}:{shoulder.elbow.wrist {thumb index middle ring pinky}:{meta prox dist} hip.knee.ankle.toes} " +
            "˚˚:{ pos:(x y z r s t) }",
             """
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


        test("robot {left right}:{shoulder.elbow.wrist {thumb index middle ring pinky}:{meta prox dist} hip.knee.ankle.toes} " +
            "˚˚ <-> .. " + // connect every node to its parent
            "˚˚:{pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000)})",
             """
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
        XCTAssertEqual(countError,0)
    }

    var result = ""
    /// add result of callback to result
    func addCallResult(_ tr3:Tr3, _ val:Tr3Val?) {
        var val = val?.printVal() ?? "nil"
        if val.first == " " { val.removeFirst() }
        result += tr3.name + ":" + val + " "
    }
    /// setup new result string, call the action, print the appeneded result
    func testAct(_ before:String,_ after:String, callTest: @escaping CallVoid) {
        result = before + " ⟹ "
        let expected = result + after
        callTest()

        if let error = ParStr.compare(expected, result) {
            print (result + "🚫 mismatch \n\(error)")
            countError += 1
        }
        else {
            print (result + "✓")
        }
        countTotal += 1
    }
    func testEdgeVal() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

        countError = 0
        // selectively set tuples by name, ignore the reset
        let script = "a:1 b->a:2"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            //let a =  root.findPath("a"),
            let b =  root.findPath("b") {

            b.activate()
            let result =  root.dumpScript(session:true)
            testCompare("√ { a:2 b->a:2 }", result)
        }

        XCTAssertEqual(countError,0)
    }
    func testEdgeVal2() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

        countError = 0
        // selectively set tuples by name, ignore the reset
        let script = "a {a1 a2} b->a.*:2"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            //let a =  root.findPath("a"),
            let b =  root.findPath("b") {

            b.activate()
            let result =  root.dumpScript(session:true)
            testCompare("√ { a { a1:2 a2:2 } b->(a.a1:2 a.a2:2) }", result)
        }

        XCTAssertEqual(countError,0)
    }
    func testEdgeVal3() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

        countError = 0
        // selectively set tuples by name, ignore the reset
        let script = "a:{b c}:{f g} z->(a˚g:2)"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            //let a =  root.findPath("a"),
            let z =  root.findPath("z") {

            z.activate()
            let result =  root.dumpScript(session:true)
            testCompare("√ { a { b { f g:2 } c { f g:2 } } z->(a.b.g:2 a.c.g:2) }", result)
        }

        XCTAssertEqual(countError,0)
    }
    func testEdgeVal4() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

        countError = 0
        // selectively set tuples by name, ignore the reset
        let script = "a:{b c}:{f g} z->(a.b.f:1 a˚g:2)"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            //let a =  root.findPath("a"),
            let z =  root.findPath("z") {

            z.activate()
            let result =  root.dumpScript(session:false)
            testCompare("√ { a { b { f:1 g:2 } c { f g:2 } } z->(a.b.f:1 a.b.g:2 a.c.g:2) }", result)
        }

        XCTAssertEqual(countError,0)
    }
    func testTuple1() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

        countError = 0
        // selectively set tuples by name, ignore the reset
        let script = "a:(x:0)<-c b:(y:0) <-c c:(x:0 y:0)"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            let c = root.findPath("c") {
            c.setVal(CGPoint(x:1,y:2), .activate)
            let result =  root.dumpScript(session:true)

            testCompare("√ { a:(1)<-c b:(2)<-c c:(1 2) }", result, echo:true)
        }

        XCTAssertEqual(countError,0)
    }
    func testTuple2() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")

        Par.trace = true
        Par.trace2 = true
        countError = 0
        let script = "a:(x y):(0...1=0)"
        print("\n" + script)
        let p0 = CGPoint(x:1, y:1)
        var p1 = CGPoint.zero

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a") {

            a.addCallback { tr3,_ in
                p1 = tr3.CGPointVal() ?? .zero
                print("p0:\(p0) => p1:\(p1)")
            }

            a.setVal(p0, [.activate])

            let result0 =  root.dumpScript(session:true)
            testCompare("√ { a:(1 1) }", result0, echo:true)
            let result1 =  root.dumpScript(session:false)
            testCompare("√ { a:(x y):(0...1=0) }", result1, echo:true)
        }
        XCTAssertEqual(p0,p1)
        Par.trace = false
        Par.trace2 = false
    }
    func testPassthrough() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
        countError = 0
        let script = "a:(0...1=0)<-b b<-c c:(0...10)<-a"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let b = root.findPath("b"),
            let c = root.findPath("c") {

            a.addCallback { tr3,_ in
                self.addCallResult(a,tr3.val!) }
            b.addCallback { tr3,_ in
                self.addCallResult(b,tr3.val!) }
            c.addCallback { tr3,_ in
                self.addCallResult(c,tr3.val!) }

            testAct("c:5.0","c:5.0 b:5.0 a:0.5") {
                c.setVal(5.0, .activate) }
            testAct("a:0.1","a:0.1 c:1.0 b:1.0 ") {
                a.setVal(0.1, .activate) }
            testAct("b:0.2","b:0.2 a:0.020000001 c:0.20000002") {
                b.setVal(0.2, .activate) }
        }
        XCTAssertEqual(countError,0)
    }

    func testTernary1() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
        countError = 0
        let script = "a b c w:0 <- (a ? 1 : b ? 2 : c ? 3)"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let b = root.findPath("b"),
            let c = root.findPath("c"),
            let w = root.findPath("w") {

            testCompare("√ { a?>w b?>w c?>w w:0<-(a ? 1 : b ? 2 : c ? 3) }", root.dumpScript(session:true), echo:true)

            w.addCallback { tr3,_ in self.addCallResult(w,tr3.val!) }
            testAct("a!", "w:1.0 ") { a.activate() }
            testAct("a:0","w:1.0")  { a.setVal(0,[.create,.activate]) }
            testAct("b!", "w:2.0 ") { b.activate() }
            testAct("b:0","w:2.0")  { b.setVal(0,[.create,.activate]) }
            testAct("c!", "w:3.0 ") { c.activate() }

            testCompare(" √ { a:0?>w b:0?>w c?>w w:3<-(a ? 1 : b ? 2 : c ? 3) }", root.dumpScript(session:true), echo:true)
        }
        XCTAssertEqual(countError,0)
    }
    func testTernary2() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
        countError = 0
        let script = "a:0 x:10 y:20 w <- (a ? x : y)"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let x = root.findPath("x"),
            let y = root.findPath("y"),
            let w = root.findPath("w") {

            testCompare("√ { a:0?>w x:10╌>w y:20╌>w w<-(a ? x : y) }", root.dumpScript(session:true), echo:true)

            w.addCallback { tr3,_ in self.addCallResult(w,tr3.val!) }
            testAct("a:0","w:20.0")  { a.setVal(0,.activate) }
            testAct("x:11","")       { x.setVal(11,.activate) }
            testAct("y:21","w:21.0") { y.setVal(21,.activate) }

            testAct("a:1","w:11.0")  { a.setVal(1,.activate) }
            testAct("x:12","w:12.0") { x.setVal(12,.activate) }
            testAct("y:22","")       { y.setVal(22,.activate) }

            testAct("a:0","w:22.0")  { a.setVal(0,.activate) }

            testCompare("√ { a:0?>w x:12╌>w y:22->w w:y<-(a ? x : y) }", root.dumpScript(session:true), echo:true)
        }
        XCTAssertEqual(countError,0)
    }
    func testTernary3() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
        countError = 0
        let script = "a x:10 y:20 w <-> (a ? x : y)"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let x = root.findPath("x"),
            let y = root.findPath("y"),
            let w = root.findPath("w") {

            testCompare("√ { a?>w x:10<╌>w y:20<╌>w w<->(a ? x : y) }", root.dumpScript(session:true), echo:true)

            w.addCallback { tr3,_ in self.addCallResult(w,tr3.val!) }
            x.addCallback { tr3,_ in self.addCallResult(x,tr3.val!) }
            y.addCallback { tr3,_ in self.addCallResult(y,tr3.val!) }
            testAct("a:0","w:20.0 y:20.0") { a.setVal(0,[.create,.activate]) }
            testAct("w:3","w:3.0 y:3.0")   { w.setVal(3,[.create,.activate]) }
            testAct("a:1","w:3.0 x:3.0")   { a.setVal(1,.activate) }
            testAct("w:4","w:4.0 x:4.0")   { w.setVal(4,[.activate]) }

            testCompare("√ { a:1?>w x:4<->w y:3<╌>w w:4<->(a ? x : y) }", root.dumpScript(session:true), echo:true)
        }
        XCTAssertEqual(countError,0)
    }
    func testEdges() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
        countError = 0
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
        XCTAssertEqual(countError,0)
    }
    #if false
    /// currently cannot bundle resource with Swift package
    func testInherit() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
        countError = 0
        let root = Tr3("√")
        func parseFile(_ fileName:String) { tr3Parse.parseTr3(root,fileName) }

        parseFile("multiline")
        parseFile("multimerge")
        let actual = root.makeScript()
        print(actual)
        XCTAssertEqual(countError,0)
    }
    func testSky() { print("\n━━━━━━━━━━━━━━━━━━━━━━ \(#function) ━━━━━━━━━━━━━━━━━━━━━━\n")
        countError = 0
        let root = Tr3("√")
        func parseFile(_ fileName:String) { tr3Parse.parseTr3(root,fileName) }

        parseFile("sky.main")
        parseFile("sky.input")
        parseFile("sky.draw")
        parseFile("sky.screen")
        parseFile("sky.cell1")
        parseFile("sky.pal")
        parseFile("sky.osc")
        parseFile("sky.draw")
        parseFile("sky.time")
        parseFile("sky.recorder")

        parseFile("_controlBase")
        parseFile("_controlRule")
        parseFile("_controlSpeed")

        parseFile("control.shader.plane")
        parseFile("control.cell.shift")

        // parseFile("control.shader.tile")
        // parseFile("control.shader.weave")

        parseFile("control.cell.rule.timeTunnel")
        parseFile("control.cell.rule.fader")
        parseFile("control.cell.rule.zhabatinski")
        parseFile("control.cell.rule.melt")
        parseFile("control.cell.rule.average")
        parseFile("control.cell.rule.slide")
        parseFile("control.cell.rule.fredkin")

        // parseFile("control.cell.rule.drift")
        // parseFile("control.cell.rule.gas")
        // parseFile("control.cell.rule.pixSort")

        parseFile("control.cell.brush")
        parseFile("control.pal.main")
        // parseFile("control.pal.rainbow")

        // parseFile("control.connect")
        // aways last to connect ruleOn, value state between dots

        let actual = root.makeScript(0,pretty:true)
        let planned =
        #"""
√ {
    sky {
        main {
        frame:0  fps:(1...60=60)
            shader { uniform.shift:(0...1=0)  fragment {{ #version 300 es

                in highp vec2 vTexCoord;
                out highp vec4 fragColor;

                precision highp float;
                uniform sampler2D drawBuf; // 2D texture
                uniform sampler2D drawPal; // 256x1 color palette for texture
                uniform float fade; // fade key slider value

                void main () {
                    vec4 realColor   = texture(drawBuf, vTexCoord.xy);
                    vec4 falseColorB = texture(drawPal, vec2(realColor.b,0.));
                    vec4 falseColorR = texture(drawPal, vec2(realColor.r,0.));
                    float fadeInverse = 1.-fade;
                    fragColor = vec4(falseColorR.r * fadeInverse + falseColorB.r * fade,
                                     falseColorR.g * fadeInverse + falseColorB.g * fade,
                                     falseColorR.b * fadeInverse + falseColorB.b * fade, 1.);
                }
            }}
                vertex {{ #version 300 es

                    in mediump vec4 aPosition;
                    in mediump vec2 aTexCoord;
                    out mediump vec2 vTexCoord;

                    void main() {
                        gl_Position = aPosition;
                        vTexCoord = aTexCoord.xy;
                    }
                }}
            }
        }
        input { shake azimuth:(x y):(-1...1=0)  force:(0...0.5=0)  accel:(x y z):(-0.3...0.3) .on:(0...1)  radius:(1...64=9)  }
        screen {
        realfake:(0...100=100)
            fade { real:(0...1000=1000)  fake:(0...1000=1000)  cross:(0...1000=1000)  }
            luma { size:(0...12700=700)  black:(0...25600=0)  white:(0...25600=25600)  }
            projector { on:(0...1=1)  width:1920  height:1080  }
        fullscreen:(%21)  dispatch:(0...1)  mode:(0...1)  limit:(%2)  type ogl.mapping
            face {
            rendertex:(%2)  automipmap:(%2)  reflection:(%2)  background:(%2)  foreground:(%2)  texture:(%2)  wireframe:(%2)
                set { background:(%2)  foreground:(%2)  wireframe:(%2)  texture:(%2)  }
                univ.wrap }
            shift {
                real { on:(0...1=1)  changed:(0...1=0)  reverse:(%2)  sum:(x y)  ofs:(x y):(-16...16=0)  add:(x y):(-16...16=0)  }
                fake { on:(0...1=1)  changed:(0...1=0)  reverse:(%2)  sum:(x y)  ofs:(x y):(-16...16=0)  add:(x y):(-16...16=0)  }
            }
            shift.fake.add<- sky.input.azimuth  }
        cell {
            _rule {
            version:(1...4=1)  mix.plane:(0...23=0)
                brush { size:(1...32=1)  index:(0...255=127)  }
            }
            rule {
                add melt zero one version:(1...4=1)  mix.plane:(0...23=0)
                brush { size:(1...32=1)  index:(0...255=127)  }
            }
        }
        pal {
            status { dyna:(0...11=0)  bw:(%2)  bwVal:(0...200=100)  }
            cycle { step:(-55...55=0)  ofs:(%256)  inc:(-16...16=0)  div:(1...30=4)  }
            change { changes:0  realpal:(0...1)  xfade:(0...255=128)  mix smooth:(1...255=255)  insert zeno:(0...1)  remove back add:(0...8)  }
            ripple { pulse:(8...240=239)  width:(16...255=12)  hue:(%3600)  sat:(0...100=100)  val:(0...100=100)  dur:(0...4=0.08)  }
            pal0:"= k k + r o y g b i v"  pal1:"= k k + w z"  }
        osc {
            in { host port:8000  message }
            out { host port:9000  message }
        brush:(0...1)  { size color }
        accxyz:(x y z):(-1...1)  msaremote.accelerometer:(x y z):(-1...1)
            tuio { prev:(x y z f)  next:(x y z f)  }
            midi.note { number:(0...127)  velocity:(0...127)  channel:(1...16)  duration }
            manos:(x y z):(0...1)  }
        time {
            clock {
                frame status
            lock:(0...1)  { fps:(0...12000=24)  base:(0...10000=1)  }
                fps:(0...120=20) .now:(0...200)  }
        adsr:(on amp dur):(0...1=1)  { global attack decay sustain release }
            lfo { type:(1...4=1)  radians:(1...8=2)  amp:(0...255=200)  dur count }
            beat { new rec stop play span now sync tick }
        }
        recorder { filename:"recorder"  useframe:(0...1=0)  loop:(0...1=1)  record pause play rewind toend erase event }
    }
    _controlBase {
        base { type:"unknown"  title:"Unknown"  frame:(x:0 y:0 w:320 h:176)  icon:"control.ring.white.png"  }
        elements.ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  }
    }
    _controlRule {
        base { type:"unknown"  title:"Unknown"  frame:(x:0 y:0 w:320 h:176)  icon:"control.ring.white.png"  }
        elements.ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  }
    }
    _controlSpeed {
        base { type:"rule"  title:"Rule"  frame:(x:0 y:0 w:320 h:222)  icon:"control.ring.white.png"  }
        elements {
            ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  }
            speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
        }
        shader.falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
        renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
    }
    control {
        shader.plane {
            base { type:"shader"  title:"Plane"  frame:(x:0 y:0 w:220 h:188)  icon:"control.shader.tile.png"  }
            elements {
                ruleOn { type:"switch"  title:"Active"  frame:(x:166 y:6 w:48 h:32)  lag:0  value:(0...1)  icon:"control.shader.tile.png"  }
                mirrorBox { type:"box"  title:"Mirror"  frame:(x:10 y:106 w:56 h:56)  radius:10  tap2:(1 1)  lag:0  master:(0...1=1)  value:(0 0):(0...1=0) -> control.shader.tile.shader.uniform.mirror  }
                repeatBox { type:"box"  title:"Repeat"  frame:(x:80 y:52 w:120 h:120)  radius:10  tap2:(-1 -1)  lag:0.5  master:(0...1=1)  value:(0 0):(0...1) -> control.shader.tile.shader.uniform.repeat  }
            }
            shader.render:"render.basic.metal"  { type:"render"  repeat:(x y) <- elements.repeatBox.value  mirror:(x y) <- elements.mirrorBox.value  }
        }
        cell {
            shift {
                base { type:"cell"  title:"Shift"  frame:(x:0 y:0 w:270 h:226)  icon:"control.shift.png"  }
                elements {
                    ruleOn { type:"switch"  title:"Active"  frame:(x:216 y:6 w:48 h:32)  lag:0  value icon:"control.shift.png"  }
                    shiftBox { type:"box"  title:"Screen Shift"  frame:(x:86 y:52 w:128 h:128)  radius:10  tap2:(-1 -1)  lag:0.5  value:(x y):(0...1=0.5) <-> sky.input.azimuth  master:(0...1)  }
                    brushTilt { type:"switch"  title:"Brush Tilt"  frame:(x:10 y:52 w:66 h:44)  icon:"control.pen.tilt.png"  value-> sky.draw.brush.tilt  }
                    accelTilt { type:"switch"  title:"Accelerometer Tilt"  frame:(x:10 y:112 w:66 h:44)  icon:"control.shift.png"  value<-> sky.input.accel.on  }
                }
                shader.cellDraw:"cell.draw.metal"  { version:(0...1=0) <- elements.version.value  scroll:(x y):(0...1) <- elements.shiftBox.value  on:(0...1=0) <- elements.ruleOn.value  type:"draw"  }
            }
            rule {
                timetunnel {
                    base { type:"rule"  title:"Time Tunnel"  frame:(x:0 y:0 w:320 h:222)  icon:"control.cell.rule.timeTunnel.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  icon }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader {
                    falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    cellTimetunnel:"cell.rule.timetunnel.metal"  { version:(0...1=0) <- elements.version.value  on:(0...1=0) <- elements.ruleOn.value  type:"compute"  }
                    }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
                fader {
                    base { type:"rule"  title:"Fader"  frame:(x:0 y:0 w:320 h:222)  icon:"control.cell.rule.fader.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  icon }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader {
                    falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    cellFader:"cell.rule.fader.metal"  { version:(0...1=0) <- elements.version.value  on:(0...1=0) <- elements.ruleOn.value  type:"compute"  }
                    }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
                zhabatinski {
                    base { type:"rule"  title:"Rule"  frame:(x:0 y:0 w:320 h:222)  icon:"control.ring.white.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader.falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
                melt {
                    base { type:"rule"  title:"Melt"  frame:(x:0 y:0 w:320 h:222)  icon:"control.cell.rule.melt.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  icon }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader {
                    falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    cellMelt:"cell.rule.melt.metal"  { version:(0...1=0) <- elements.version.value  on:(0...1=0) <- elements.ruleOn.value  type:"compute"  }
                    }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
                average {
                    base { type:"rule"  title:"Average"  frame:(x:0 y:0 w:320 h:222)  icon:"control.cell.rule.average.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  icon }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader {
                    falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    cellAverage:"cell.rule.average.metal"  { version:(0...1=0) <- elements.version.value  on:(0...1=0) <- elements.ruleOn.value  type:"compute"  }
                    }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
                slide {
                    base { type:"rule"  title:"Slide Bit Planes"  frame:(x:0 y:0 w:320 h:222)  icon:"control.cell.rule.slide.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  icon }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader {
                    falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    cellSlide:"cell.rule.slide.metal"  { version:(0...1=0) <- elements.version.value  on:(0...1=0) <- elements.ruleOn.value  type:"compute"  }
                    }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
                fredkin {
                    base { type:"rule"  title:"Fredkin"  frame:(x:0 y:0 w:320 h:222)  icon:"control.cell.rule.fredkin.png"  }
                    elements {
                        ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  lag:0  value:(0...1=0)  icon }
                        speed { type:"slider"  title:"Frames per second"  frame:(x:70 y:164 w:192 h:44)  icon:"control.pearl.white.png"  value:(1...60=60) <-> sky.main.fps  }
                    }
                    shader {
                    falseColor:"falseColor.metal"  { type:"colorize"  shift:(0...1=0) <- elements.plane.value  }
                    cellFredkin:"cell.rule.fredkin.metal"  { version:(0...1=0) <- elements.version.value  on:(0...1=0) <- elements.ruleOn.value  type:"compute"  }
                    }
                    renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
                }
            }
            brush {
                base { type:"brush"  title:"Brush"  frame:(x:0 w:0 w:320 h:168)  icon:"control.cell.brush.png"  }
                elements {
                    fillZero { type:"trigger"  title:"clear 0"  frame:(x:4 y:50 w:44 h:44)  icon:"control.drop.clear.png"  value:(0...1=0) -> sky.cell.rule.zero  }
                    fillOne { type:"trigger"  title:"clear 0xFFFF"  frame:(x:266 y:50 w:44 h:44)  icon:"control.drop.gray.png"  value:(0...1=0) -> sky.cell.rule.one  }
                    palScrub { type:"slider"  title:"Scrub Palette"  frame:(x:64 y:50 w:192 h:44)  value:(0...1=0) <-> sky.draw.brush.index  }
                    brushPress { type:"switch"  title:"Pressure"  frame:(x:10 y:108 w:66 h:44)  icon:"control.pen.press.png"  value:(0...1=0) <->(brushSize.master ? 0 ) <-(brushSize.master ? 0 )  }
                    brushSize { type:"slider"  title:"Size"  frame:(x:86 y:108 w:206 h:44)  value:(0...1) <-> sky.draw.brush.size  master:(0...1)  }
                    brushPress.value:0 <-(brushSize.master ? 0 )  }
                renderer { zero:(0...1=0) <- elements.fillZero.value  one:(0...1=0) <- elements.fillOne.value  }
            }
        }
        pal.main {
            base { type:"palette"  title:"Palette"  frame:(x:0 y:0 w:320 h:176)  icon:"control.pal.main.png"  }
            elements {
                ruleOn { type:"switch"  title:"Active"  frame:(x:266 y:6 w:48 h:32)  icon:"control.pal.main.png"  lag:0  value:0  }
                fillZero { type:"trigger"  title:"fill 0"  frame:(x:10 y:50 w:44 h:44)  icon:"control.drop.clear.png"  value:(0...1=0) -> sky.cell.rule.zero  }
                palFade { type:"slider"  title:"Pal A <-> B"  frame:(x:64 y:50 w:192 h:44)  icon:"control.pearl.white.png"  lag:0.25  value:(0...1=0) <-> sky.pal.change.xfade  }
                fillOne { type:"trigger"  title:"fill 1"  frame:(x:260 y:50 w:44 h:44)  icon:"control.drop.gray.png"  value:(0...1=0) -> sky.cell.rule.one  }
                shiftLeft { type:"trigger"  title:"Shift Left"  frame:(x:10 y:108 w:44 h:44)  icon:"control.arrow.left.png"  value:(0...255=0) -> sky.pal.cycle.inc  }
                palScrub { type:"slider"  title:"Scrub Palette"  frame:(x:64 y:108 w:192 h:44)  icon:"control.cell.brush.png"  value:(0...1=0) <-> sky.draw.brush.index  }
                shiftRight { type:"trigger"  title:"Shift Right"  frame:(x:260 y:108 w:44 h:44)  icon:"control.arrow.right.png"  value:(0...255=0) -> sky.pal.cycle.inc  }
            }
        }
    }
}
"""#
        testCompare(planned, actual, echo:true)
        //print(actual)
        let d3Script = root.makeD3Script()
        print(d3Script)
        XCTAssertEqual(countError,0)
    }
    #endif

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
        //("testInherit",testInherit),
        //("testSky",testSky),
    ]
}
