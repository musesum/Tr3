import CoreFoundation
import XCTest
import Par

@testable import Tr3

final class Tr3Tests: XCTestCase {

    var tr3Parse = Tr3Parse()

    /** Test script produces expected output
     - parameter script: test script
     - parameter expected: exected output after parse
     */
    func test(_ script: String, _ expected: String? = nil, session: Bool = false) -> Int {

        var err = 0

        print(script)
        let root = Tr3("√")
        let expected = expected ?? "√ { \(script) }"

        if tr3Parse.parseScript(root, script, whitespace: "\n\t ") {

            let actual = root.dumpScript(indent: 0, session: session)
            err = ParStr.testCompare(expected, actual)
        }
        else  {
            print(" 🚫 failed parse")
            err += 1  // error found
        }
        return err
    }

    func headline(_ title: String) {
        //let titled = title.titleCase()
        print("\n━━━━━━━━━━━━━━━━━━━━━━ \(title) ━━━━━━━━━━━━━━━━━━━━━━\n")
    }
    func subhead(_ title: String) {
        //let titled = title.titleCase()
        print("━━━━━━━━━━━ \(title) ━━━━━━━━━━━")
    }
    func read(_ filename: String) -> String? {
        let url = Bundle.module.url(forResource: filename, withExtension: "tr3.h")
        if let path = url?.path {
            do { return try String(contentsOfFile: path) } catch {}
        }
        print("🚫 \(#function) cannot find:\(filename)")
        return nil
    }
    func parse(_ name: String,_ root: Tr3) -> Int {
        if let script = read(name),
           Tr3Parse().parseScript(root, script, whitespace: "\n\t ") {
            print (name +  " ✓")
            return 0
        } else {
            print(name + " 🚫 parse failed")
            return 1
        }
    }
    func testFile(_ input: String, out: String)  -> Int {
        let root = Tr3("√")
        if let script = read(input),
           Tr3Parse().parseScript(root, script, whitespace: "\n\t ") {
            print (name +  " ✓")
            let actual = root.dumpScript(indent: 0)
            let expect = read(out) ?? ""
            let err = ParStr.testCompare(expect, actual)
            return err
        } else {
            return 1 // error
        }
    }
    func testParseShort() { headline(#function)
        var err = 0

        err += test(
            /**/"abcdefghijklmnopqrstu1 abcdefghijklmnopqrstu2")

        err += test("a { b { c(1) } } a.b.c(2)", "√ { a { b { c(2) } } }")

        err += test(
            /**/"a { b { c(1) } } z: a { b.c(2) }",
            "√ { a { b { c(1) } } z: a { b { c(2) } } }")

        err += test("a, b { // yo \n c }")
        err += test("a { b { // yo \n c } } ")
        err += test("a { b { /* yo */ c } } ")
        err += test("a { b { /** yo **/ c } } ")

        err += test("a b c => a")

        err += test("a b c d a << (b ? c : d)", "√ { a <<(b ? c : d ) b⋯>a c>>a d>>a }")

        err += test("value(1.67772e+07)", "√ { value(1.67772e+07) }")

        err += test("a.b.c(0..1) z: a { b.c(0..1 = 1) }",
                    "√ { a { b { c(0..1) } } z: a { b { c(0..1 = 1) } } }")

        err += test("a {b c}.{d e}.{f g}.{h i} z >> a.b˚g.h",
                    "√ { a { b { d { f { h i } g { h i } } e { f { h i } g { h i } } } " +
                        "    c { d { f { h i } g { h i } } e { f { h i } g { h i } } } } " +
            " z >> (d.g.h e.g.h) }")

        err += test("a {b c}.{d e f>>b(1) } z: a z.b.f=>c(1) ",
                    "√ { a   { b { d e f>>a.b(1) } c { d e f>>a.b(1) } }" +
                        "z: a { b { d e f=>z.c(1) } c { d e f>>z.b(1) } } }")

        err += test("a._c { d { e { f \"ff\" } } } a.c.z: _c { d { e.f    \"ZZ\" } }",
                    "√ { a { _c { d { e { f \"ff\" } } } c { z: _c { d { e { f \"ZZ\" } } } } } }")

        err += test("a.b { _c { d e.f(0..1) g} z: _c { g } } ",
                    "√ { a { b { _c { d e { f(0..1) } g } z: _c { d e { f(0..1) } g } } } }")

        err += test("a.b._c {d(1)} a.b.e: _c", "√ { a { b { _c { d(1) } e: _c { d(1) } } } }")

        err += test("a {b c}.{d e}.{f g}.{i j} a.b˚f << (f.i ? f.j : 0) ",
                    "√ { a { b { d { f << (f.i ? f.j : 0) { i⋯>b.d.f j>>b.d.f } g { i j } }" +
                        "        e { f << (f.i ? f.j : 0) { i⋯>b.e.f j>>b.e.f } g { i j } } }" +
                        "    c { d { f { i j } g { i j } }" +
                        "        e { f { i j } g { i j } } } } a.b˚f << (f.i ? f.j : 0 ) }" +
                        "")

        err += test("a {b c}.{d e}.{f g}.{i j} a.b˚f << (f.i ? f.j : 0) ",
                    "√ { a { b { d { f << (f.i ? f.j : 0) { i⋯>b.d.f j>>b.d.f } g { i j } }" +
                        "        e { f << (f.i ? f.j : 0) { i⋯>b.e.f j>>b.e.f } g { i j } } }" +
                        "    c { d { f { i j } g { i j } }" +
                        "        e { f { i j } g { i j } } } } a.b˚f << (f.i ? f.j : 0 ) }" +
                        "")

        err += test("a {b c}.{d << (b ? 1 | c ? 2) e } z: a z.b.d << (b ? 5 | c ? 6)",
                    "√ { a { b⋯>(a.b.d a.c.d) { d << (b ? 1 | c ? 2) e } " +
                       "     c⋯>(a.b.d a.c.d) { d << (b ? 1 | c ? 2) e } } " +
                       "z: a{ b⋯>(z.b.d z.c.d) { d << (b ? 5 | c ? 6) e } " +
                       "     c⋯>(z.b.d z.c.d) { d << (b ? 1 | c ? 2) e } } }" +
            "")


        err += test("a b >> a(1)", "√ { a b >> a(1) }")

        err += test("a << (b c)", "√ { a << (b c) }")

        err += test(     "a, b.c << (a ? 1) d: b ",
                    "√ { a⋯>(b.c d.c), b { c << (a ? 1 ) } d: b { c << (a ? 1 ) } }")
        
        err += test("a {b << (a ? 1) c} ", "√ { a⋯>a.b { b << (a ? 1 ) c } }")
        
        err += test("a {b c}.{d << (b ? 1 | c ? 2) e} ",
                    "√ { a { b⋯>(a.b.d a.c.d) { d << (b ? 1 | c ? 2) e } " +
                        /**/"c⋯>(a.b.d a.c.d) { d << (b ? 1 | c ? 2) e } } }")

        err += test("a b c w << (a ? 1 : b ? 2 : c ? 3)",
                    "√ { a⋯>w b⋯>w c⋯>w w << (a ? 1 : b ? 2 : c ? 3) }")

        err += test("a.b { c d } a.e: a.b { f g } ", "√ { a { b { c d } e: a.b { c d f g } } }")

        err += test(    "a { b c } d: a { e f } g: d { h i } j: g { k l }",
                        "√ { a { b c } d: a { b c e f } g: d { b c e f h i } j: g { b c e f h i k l } }")

        err += test("a { b c }    h: a { i j }", "√ { a { b c } h: a { b c i j } }")
        err += test("a { b c } \n h: a { i j }", "√ { a { b c } h: a { b c i j } }")

        XCTAssertEqual(err, 0)
    }

    /// compare script with expected output and print an error if they don't match
    func testParseBasics() { headline(#function)

        var err = 0
        err += test("a \"yo\"")
        err += test("a { b \"bb\" }")
        err += test("a { b \"bb\" c \"cc\" }")

        subhead("comment")
        err += test("a // yo", "√ { a }")
        err += test("a { b } // yo", "√ { a { b } }")
        err += test("a { b // yo \n } ", "√ { a { b // yo \n } }")
        err += test("a { b { // yo \n c } } ", "√ { a { b { // yo \n c } } }")
        // error err += test("a b a // yo \n << b // oy\n", "√ { a // yo \n << b // oy\n b }")

        subhead("hierarchy")
        err += test("a { b c }", "√ { a { b c } }")
        err += test("a { b { c } }", "√ { a { b { c } } }")
        err += test("a { b { c } d { e } }", "√ { a { b { c } d { e } } }")
        err += test("a { b { c d } e }", "√ { a { b { c d } e } }")

        subhead("many")
        err += test("a {b c}.{d e}", "√ { a { b { d e } c { d e } } }")
        err += test("a {b c}.{d e}.{f g}", "√ { a { b { d { f g } e { f g } } c { d { f g } e { f g } } } }")
        
        subhead("copyat")
        err += test("a {b c} d: a ", "√ { a { b c } d: a { b c } }")
        err += test("_a { b { c \"yo\" } } d: _a { b { c \"oy\" } }")

        XCTAssertEqual(err, 0)
    }

    func testParsePathCopy() { headline(#function)
        var err = 0
        err += test("a.b.c { b { d } }", "√ { a { b { c { b { d } } } } }")
        err += test("a.b { c d } e: a { b.c(0) }", "√ { a { b { c d } } e: a { b { c(0) d } } }")
        err += test("a { b { c } } a.b <> c ", "√ { a { b <> a.b.c { c } } } ")

        err += test("a { b { c d } } e { b { c d } b(0) }" ,
                    "√ { a { b { c d } } e { b(0) { c d } } }")

        err += test("a {b c}.{d e}.{f g}.{i j} a.b˚f << (f.i ? f.j : 0) ",
                    "√ { a { b { d { f << (f.i ? f.j : 0 ) { i⋯>b.d.f j >> b.d.f } g { i j } }" +
                        "        e { f << (f.i ? f.j : 0 ) { i⋯>b.e.f j >> b.e.f } g { i j } } }" +
                        "    c { d { f { i j } g { i j } }" +
                        "        e { f { i j } g { i j } } } } a.b˚f << (f.i ? f.j : 0 ) }" +
                        "")

        XCTAssertEqual(err, 0)
    }

    func testParseValues() { headline(#function)
        var err = 0
        err += test("a(1)")
        err += test("a(1..2)")
        err += test("a(1, 2)")
        err += test("a(x 1, y 2)")
        err += test("a(%2)")
        err += test("b(x %2, y %2)")
        err += test("b(x 1, y 2)")
        err += test("m(1, 2, 3)")
        err += test("m(1, 2, 3), n >> m(4, 5, 6)")
        err += test("i(1..2 = 1.5, 3..4 = 3.5, 5..6 = 5.5)")
        err += test("b(x 1, y 2)")
        err += test("b(x 1, y 2)")
        err += test("a(%2)")
        err += test("a(x 1..2, y 1..2)")
        err += test("a(x 0..1 = 0.5, y 0..1 = 0.5)")
        err += test("a(0..1 = 0.5) { b(1..2) { c(2..3) } }")
        err += test("a(x 0..1 = 0.5, y 0..1 = 0.5)")

        print("\n━━━━━━━━━━━━━━━━━━━━━━ tr3 scalars ━━━━━━━━━━━━━━━━━━━━━━\n")
        err += test("a { b(2) { c } }", "√ { a { b(2) { c } } }")
        err += test("a(1) { b(2) { c(3) } }", "√ { a(1) { b(2) { c(3) } } }")
        err += test("a(0..1 = 0.5) { b(1..2) { c(2..3) } }", "√ { a(0..1 = 0.5) { b(1..2) { c(2..3) } } }")
        err += test("a(%2) b(%2)", "√ { a(%2) b(%2) }")

        print("\n━━━━━━━━━━━━━━━━━━━━━━ tr3 tuples ━━━━━━━━━━━━━━━━━━━━━━\n")
        err += test("a(x 0..1 = 0.5, y 0..1 = 0.5)", "√ { a(x 0..1 = 0.5, y 0..1 = 0.5) }")
        err += test("a(x 1..2, y 1..2)")
        err += test("b(x -1, y 2)")
        err += test("c(x 3, y 4)")
        err += test("d(x, y, z)")
        err += test("m(0, 0, 0), n >> m(1, 1, 1)", "√ { m(0, 0, 0), n >> m(1, 1, 1) }")
        err += test("m(0, 0, 0), n(1, 1, 1) >> m", "√ { m(0, 0, 0), n(1, 1, 1) >> m }")
        err += test("e(x -16..16, y -16..16)", "√ { e(x -16..16, y -16..16) }")
        err += test("f(p 0..1, q 0..1, r 0..1)", "√ { f(p 0..1, q 0..1, r 0..1) }")
        err += test("g(p 0..1 = 0.5, q 0..1 = 0.5, r 0..1 = 0.5)", "√ { g(p 0..1 = 0.5, q 0..1 = 0.5, r 0..1 = 0.5) }")
        err += test("h(p 0..1 = 0.5, q 0..1 = 0.5, r 0..1 = 0.5)", "√ { h(p 0..1 = 0.5, q 0..1 = 0.5, r 0..1 = 0.5) }")
        err += test("i(0..1 = 0.5, 0..1 = 0.5, 0..1 = 0.5)", "√ { i(0..1 = 0.5, 0..1 = 0.5, 0..1 = 0.5) }")
        err += test("j(one 1, two 2)")
        err += test("k(one \"1\", two \"2\")")
        XCTAssertEqual(err, 0)
    }

    func testParsePaths() { headline(#function)
        var err = 0
        err += test("a { b { c {c1 c2} d } } a e", "√ { a { b { c { c1 c2 } d } } e }")
        err += test("a { b { c d } } a { e }", "√ { a { b { c d } e } }")
        err += test("a { b { c {c1 c2} d } b.c { c3 } }", "√ { a { b { c { c1 c2 c3 } d } } }")
        err += test("a { b { c {c1 c2} d } b.c { c2(2) c3 } }", "√ { a { b { c { c1 c2(2) c3 } d } } }")
        err += test("a { b { c d } b.e }", "√ { a { b { c d e } } }")
        err += test("a { b { c d } b.e.f }", "√ { a { b { c d e { f } } } }")

        err += test("a { b { c {c1 c2} d {d1 d2} } b.c: b.d  }", "√ { a { b { c { c1 c2 d1 d2 } d { d1 d2 } } } }")
        err += test("a { b { c d } } a: e", "√ { a { b { c d } e } }")
        err += test("ab { a(1) b(2) } cd: ab { a(3) c(4) d(5) } ef: cd { b(6) d(7) e(8) f(9) }",
                    "√ { ab { a(1) b(2) } cd: ab { a(3) b(2) c(4) d(5) } ef: cd { a(3) b(6) c(4) d(7) e(8) f(9) } }")

        err += test("ab { a(1) b(2) } ab { c(4) d(5) }", "√ { ab { a(1) b(2) c(4) d(5) } }")

        err += test("ab { a(1) b(2) } cd { c(4) d(5) } ab˚.: cd",
                "√ { ab { a(1) { c(4) d(5) } b(2) { c(4) d(5) } } cd { c(4) d(5) } }")

        err += test("a.b { _c { c1 c2 } c: _c { d e } }",
              "√ { a { b { _c { c1 c2 } c: _c { c1 c2 d e } } } }")

        err += test("a.b { _c { c1 c2 } c { d e }: _c }",
              "√ { a { b { _c { c1 c2 } c: _c { d e c1 c2 } } } }")

        err += test("a.b.c.d { e.f }", "√ { a { b { c { d { e { f } } } } } }")
        XCTAssertEqual(err, 0)
    }

    func testParseEdges() { headline(#function)
        var err = 0
        err += test("a b c << b", "√ { a b c << b }")
        err += test("a, b, c >> b", "√ { a, b, c >> b }")
        err += test("a { a1, a2 } w << a.* ", "√ { a { a1, a2 } w << (a.a1 a.a2) }")
        err += test("a { b { c } } a <> .* ", "√ { a <> a.b { b { c } } }")
        err += test("a { b { c } } a.b <> c ", "√ { a { b <> a.b.c { c } } } ")
        err += test("a { b { c } } a˚˚ <> .* ", "√ { a <> a.b { b <> a.b.c { c } } a˚˚ <> .* }")
        err += test("a { b { c } } ˚˚ <> .. ", "√ { a <> √ { b <> a { c <> a.b } } ˚˚ <> .. }")

        subhead("multi edge")
        err += test("a << (b c)")
        err += test("a << (b c) { b c }", "√ { a << (a.b a.c) { b c } }")
        err += test("a >> (b c) { b c }", "√ { a >> (a.b a.c) { b c } }")

        subhead("copyat edge")
        err += test("a {b c} z: a <: a ",
                    "√ { a { b c } z: a <: a { b <: a.b c <: a.c } }")

        err += test("a {b c}.{d e} z: a <: a",
        """
        √ { a { b { d e } c { d e } }
          z: a <: a { b <: a.b { d <: a.b.d e <: a.b.e }
                    c <: a.c { d <: a.c.d e <: a.c.e } } }
        """)

        XCTAssertEqual(err, 0)
    }

    func testParseTernarys() { headline(#function)
        var err = 0
        err += test("a b x y w << (a ? 1 : b ? 2)", "√ { a⋯>w b⋯>w x y w << (a ? 1 : b ? 2) }")
        err += test("a, x, y, w << (a ? x : y)", "√ { a⋯>w, x╌>w, y╌>w, w << (a ? x : y) }")
        err += test("a, x, y, w >> (a ? x : y)", "√ { a⋯>w, x<╌w, y<╌w, w >> (a ? x : y) }")
        err += test("a(1), x, y, w << (a ? x : y)", "√ { a(1)⋯>w, x >> w, y╌>w, w << (a ? x : y) }")
        err += test("a(1), x, y, w >> (a ? x : y)", "√ { a(1)⋯>w, x << w, y<╌w, w >> (a ? x : y) }")
        err += test("a(0), x, y, w << (a ? x : y)", "√ { a(0)⋯>w, x╌>w, y╌>w, w << (a ? x : y) }")
        err += test("a(0), x, y, w >> (a ? x : y)", "√ { a(0)⋯>w, x<╌w, y<╌w, w >> (a ? x : y) }")

        err += test("a, x, y, w <>(a ? x : y)", "√ { a⋯>w, x<╌>w, y<╌>w, w <> (a ? x : y) }")

        err += test("a, b, x, y, w << (a ? x : b ? y)", "√ { a⋯>w, b⋯>w, x╌>w, y╌>w, w << (a ? x : b ? y) }")
        err += test("a, b, x, y, w << (a ? 1 : b ? 2)", "√ { a⋯>w, b⋯>w, x, y, w << (a ? 1 : b ? 2) }")
        err += test("a b c w << (a ? 1 : b ? 2 : c ? 3)", "√ { a⋯>w b⋯>w c⋯>w w<<(a ? 1 : b ? 2 : c ? 3) }")
        err += test("a, b, c, w << (a ? 1 : b ? 2 : c ? 3)", "√ { a⋯>w, b⋯>w, c⋯>w, w << (a ? 1 : b ? 2 : c ? 3) }")
        err += test("a, b, c, x << (a ? b ? c ? 3 : 2 : 1)", "√ { a⋯>x, b⋯>x, c⋯>x, x << (a ? b ? c ? 3 : 2 : 1) }")
        err += test("a, b, c, y << (a ? (b ? (c ? 3) : 2) : 1)", "√ { a⋯>y, b⋯>y, c⋯>y, y << (a ? b ? c ? 3 : 2 : 1) }")
        err += test("a, b, c, z << (a ? 1) << (b ? 2) << (c ? 3)", "√ { a⋯>z, b⋯>z, c⋯>z, z << (a ? 1) << (b ? 2) << (c ? 3) }")
        err += test("a, b, w << (a ? 1 : b ? 2 : 3)", "√ { a⋯>w, b⋯>w, w << (a ? 1 : b ? 2 : 3) }"  )
        err += test("a, b, w <> (a ? 1 : b ? 2 : 3)", "√ { a⋯>w, b⋯>w, w <> (a ? 1 : b ? 2 : 3) }"  )

        subhead("ternary conditionals")

        err += test("a1, b1, a2, b2, w << (a1 == a2 ? 1 : b1 == b2 ? 2 : 3)",
                    "√{ a1⋯>w, b1⋯>w, a2⋯>w, b2⋯>w, w << (a1 == a2 ? 1 : b1 == b2 ? 2 : 3 ) }")

        err += test("d {a1 a2}.{b1 b2}.{c1 c2} h << (d.a1 ? b1 ? c1 : 1)",
                    "√ { d { a1⋯>h { b1⋯>h { c1╌>h c2 } b2 { c1 c2 } } a2 { b1 { c1 c2 } b2 { c1 c2 } } } h << (d.a1 ? b1 ? c1 : 1) }")

        subhead("ternary paths")

        err += test("a {b c}.{d e}.{f g} a << a˚d.g",
                    "√ { a << (b.d.g c.d.g) { b { d { f g } e { f g } } c { d { f g } e { f g } } } }")

        err += test("a {b c}.{d e}.{f g}.{i j} a.b˚f << (f.i == f.j ? 1 : 0) ",
                    "√ { a { b { d { f << (f.i == f.j ? 1 : 0 ) { i⋯>b.d.f j⋯>b.d.f } g { i j } }" +
                        "        e { f << (f.i == f.j ? 1 : 0 ) { i⋯>b.e.f j⋯>b.e.f } g { i j } } }" +
                        "    c { d { f { i j } g { i j } }" +
                        "        e { f { i j } g { i j } } } } a.b˚f << (f.i == f.j ? 1 : 0) }" +
                        "")

        err += test("a {b c}.{d e}.{f g}.{i j} a.b˚f << (f.i ? f.j : 0) ",
                    "√ { a { b { d { f << (f.i ? f.j : 0 ) { i⋯>b.d.f j>>b.d.f } g { i j } }" +
                        "        e { f << (f.i ? f.j : 0 ) { i⋯>b.e.f j>>b.e.f } g { i j } } }" +
                        "    c { d { f { i j } g { i j } }" +
                        "        e { f { i j } g { i j } } } } a.b˚f << (f.i ? f.j : 0 ) }" +
            "")

        subhead("ternary radio")

        err += test("a, b, c, x, y, z, w << (a ? 1 | b ? 2 | c ? 3)",
                    "√ { a⋯>w, b⋯>w, c⋯>w, x, y, z, w << (a ? 1 | b ? 2 | c ? 3 ) } ")
        err += test("a, b, c, x, y, z, w << (a ? x | b ? y | c ? z)",
                    "√ { a⋯>w, b⋯>w, c⋯>w, x╌>w, y╌>w, z╌>w, w << (a ? x | b ? y | c ? z) }")
        err += test("a, b, c, x, y, z, w <> (a ? x | b ? y | c ? z)",
                    "√ { a⋯>w, b⋯>w, c⋯>w, x<╌>w, y<╌>w, z<╌>w, w <> (a ? x | b ? y | c ? z) }")

        err += test("a {b c}.{d e}.{f g}.{i j} a.b˚f << (f.i ? 1 | a˚j ? 0) ",
                    "√ { a { b { d { f << (f.i ? 1 | a˚j ? 0 ) { i⋯>b.d.f j⋯>(b.d.f b.e.f) } g { i j⋯>(b.d.f b.e.f) } } " +
                        "        e { f << (f.i ? 1 | a˚j ? 0 ) { i⋯>b.e.f j⋯>(b.d.f b.e.f) } g { i j⋯>(b.d.f b.e.f) } } } " +
                        "    c { d { f { i j⋯>(b.d.f b.e.f) } g { i j⋯>(b.d.f b.e.f) } } " +
                        "        e { f { i j⋯>(b.d.f b.e.f) } g { i j⋯>(b.d.f b.e.f) } } } } a.b˚f << (f.i ? 1 | a˚j ? 0 ) }" +
            "")
        XCTAssertEqual(err, 0)
    }

    func testParseRelativePaths() { headline(#function)
        var err = 0
        err += test("d {a1 a2}.{b1 b2} e << d˚b1", "√ { d { a1 { b1 b2 } a2 { b1 b2 } } e << (d.a1.b1 d.a2.b1) }")
        err += test("d {a1 a2}.{b1 b2} e << d˚˚", "√ { d { a1 { b1 b2 } a2 { b1 b2 } } e << (d d.a1 d.a1.b1 d.a1.b2 d.a2 d.a2.b1 d.a2.b2)  }")
        err += test("d {a1 a2}.{b1 b2} e << (d˚b1 ? d˚b2)", "√ { d { a1 { b1⋯>e b2╌>e } a2 { b1⋯>e b2╌>e } } e << (d˚b1 ? d˚b2) }")
        err += test("d {a1 a2}.{b1 b2} e << (d.a1 ? a1.* : d.a2 ? a2.*)", "√ { d { a1⋯>e { b1╌>e b2╌>e } a2⋯>e { b1╌>e b2╌>e } } e << (d.a1 ? a1.* : d.a2 ? a2.*) }")
        err += test("d {a1 a2}.{b1 b2} e << (d.a1 ? .*   : d.a2 ? .*)",   "√ { d { a1⋯>e { b1╌>e b2╌>e } a2⋯>e { b1╌>e b2╌>e } } e << (d.a1 ? .* : d.a2 ? .*) }")
        err += test("d {a1 a2}.{b1 b2} e << (d˚a1 ? a1˚. : d˚a2 ? a2˚.)", "√ { d { a1⋯>e { b1╌>e b2╌>e } a2⋯>e { b1╌>e b2╌>e } } e << (d˚a1 ? a1˚. : d˚a2 ? a2˚.) }")

        err += test("d {a1 a2}.{b1 b2}.{c1 c2} e << (d˚b1 ? b1˚. : d˚b2 ? b2˚.)",
                    "√ { d { a1 { b1⋯>e { c1╌>e c2╌>e } b2⋯>e { c1╌>e c2╌>e } } a2 { b1⋯>e { c1╌>e c2╌>e } b2⋯>e { c1╌>e c2╌>e } } } e<<(d˚b1 ? b1˚. : d˚b2 ? b2˚.) }")

        err += test("d {a1 a2}.{b1 b2}.{c1 c2} e << (d˚b1 ? b1˚. | d˚b2 ? b2˚.)",
                    "√ { d { a1 { b1⋯>e { c1╌>e c2╌>e } b2⋯>e { c1╌>e c2╌>e } } a2 { b1⋯>e { c1╌>e c2╌>e } b2⋯>e { c1╌>e c2╌>e } } } e<<(d˚b1 ? b1˚. | d˚b2 ? b2˚.) }")

        err += test("d {a1 a2}.{b1 b2}.{c1 c2} h << (d.a1 ? b1 ? c1 : 1)",
                    "√ { d { a1⋯>h { b1⋯>h { c1╌>h c2 } b2 { c1 c2 } } a2 { b1 { c1 c2 } b2 { c1 c2 } } } h<<(d.a1 ? b1 ? c1 : 1) }")

        err += test("d {a1 a2}.{b1 b2}.{c1 c2} " +
                        "e << (d˚b1 ? b1˚. : d˚b2 ? b2˚.) " +
                        "f << (d˚b1 ? b1˚. : b2˚.) " +
                        "g << (d˚b1 ? b1˚.) <<(d˚b2 ? b2˚.) " +
                        "h << (d.a1 ? b1 ? c1 : 1) " +
                        "i << (d˚b1 ? b1˚. | d˚b2 ? b2˚.)",

                    "√ { d { " +
                        "a1⋯>h { b1⋯>(e f g h i) { c1╌>(e f g h i) c2╌>(e f g i) } b2⋯>(e g i) { c1╌>(e f g i) c2╌>(e f g i) } } " +
                        "a2   { b1⋯>(e f g i)   { c1╌>(e f g i)   c2╌>(e f g i) } b2⋯>(e g i) { c1╌>(e f g i) c2╌>(e f g i) } } } " +
                        "e << (d˚b1 ? b1˚. : d˚b2 ? b2˚.) " +
                        "f << (d˚b1 ? b1˚. : b2˚.) " +
                        "g << (d˚b1 ? b1˚.) << (d˚b2 ? b2˚.) " +
                        "h << (d.a1 ? b1 ? c1 : 1) " +
                        "i << (d˚b1 ? b1˚. | d˚b2 ? b2˚.) }" +
                        "")

        err += test("d {a1 a2}.{b1 b2}.{c1 c2} e << (d˚b1 ? b1˚. : d˚b2 ? b2˚.) ",
                    "√ { d { " +
                        "a1 { b1⋯>e { c1╌>e c2╌>e } b2⋯>e { c1╌>e c2╌>e } } " +
                        "a2 { b1⋯>e { c1╌>e c2╌>e } b2⋯>e { c1╌>e c2╌>e } } } " +
                        "e<<(d˚b1 ? b1˚. : d˚b2 ? b2˚.) }" +
            "")

        err += test("w {a b}.{c d}.{e f}.{g h} x << (w˚c ? c˚. : w˚d ? d˚.) ",
                    "√ { w { " +
                        "a { c⋯>x { e { g╌>x h╌>x } f { g╌>x h╌>x } } d⋯>x { e { g╌>x h╌>x } f { g╌>x h╌>x } } } " +
                        "b { c⋯>x { e { g╌>x h╌>x } f { g╌>x h╌>x } } d⋯>x { e { g╌>x h╌>x } f { g╌>x h╌>x } } } } " +
                        "x<<(w˚c ? c˚. : w˚d ? d˚.) }" +
            "")
        XCTAssertEqual(err, 0)
    }



    /// global result to tes callback
    var result = ""

    /// add result of callback to result
    func addCallResult(_ tr3: Tr3, _ val: Tr3Val?) {
        var val = val?.printVal() ?? "nil"
        if val.first == " " { val.removeFirst() }
        result += tr3.name + "(" + val + ")"
    }

    /// setup new result string, call the action, print the appeneded result
    func testAct(_ before: String, _ after: String, callTest: @escaping CallVoid) -> Int {
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

    /// test `b >> a(2)` for `b!`
    func testEdgeVal() { headline(#function)
        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a(1) b >> a(2)"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            //let a =  root.findPath("a"),
            let b =  root.findPath("b") {

            b.activate()
            let result =  root.dumpScript(indent: 0, session: true)
            err = ParStr.testCompare("√ { a(2) b >> a(2) }", result)
        }
        else {
            err = 1
        }
        XCTAssertEqual(err, 0)
    }

    /// test `b >> a.*(2)` for `b!`
    func testEdgeVal2() { headline(#function)

        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a {a1 a2} b >> a.*(2)"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            //let a = root.findPath("a"),
            let b = root.findPath("b") {

            b.activate()
            let result = root.dumpScript(indent: 0, session: true)
            err = ParStr.testCompare("√ { a { a1(2) a2(2) } b >> (a.a1(2) a.a2(2)) }", result)
        }
        else {
            err = 1
        }
        XCTAssertEqual(err, 0)
    }

    /// test `a {b c}.{f g}`
    func testEdgeVal3a() { headline(#function)

        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a {b c}.{f g}"
        print("\n" + script)

        let root = Tr3("√")
        
        if tr3Parse.parseScript(root, script) {
            let result = root.dumpScript(indent: 0, session: true)
            err += ParStr.testCompare("√ { a { b { f g } c { f g } } }", result)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err, 0)
    }

    /// test `a {b c}.{f g} z >> a˚g(2)`
    func testEdgeVal3b() { headline(#function)

        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a {b c}.{f g} z >> a˚g(2)"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            //let a =  root.findPath("a"),
            let z =  root.findPath("z") {
            z.activate()
            let result = root.dumpScript(indent: 0, session: true)
            err += ParStr.testCompare("√ { a { b { f g(2) } c { f g(2) } } z >> (a.b.g(2) a.c.g(2)) }", result)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err, 0)
    }

    /// test `z >> a.b.f(1) >> a˚g(2)`
    func testEdgeVal4() { headline(#function)
        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a {b c}.{f g} z >> a.b.f(1) >> a˚g(2)"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            //let a =  root.findPath("a"),
            let z =  root.findPath("z") {

            z.activate()
            let result =  root.dumpScript(indent: 0, session: false)
            err += ParStr.testCompare("√ { a { b { f(1) g(2) } c { f g(2) } } z >> (a.b.f(1) a.b.g(2) a.c.g(2)) }", result)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err, 0)
    }

    /// test `z: a <: a`
    func testCopyAtR1() { headline(#function)
        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a {b(1) c(2)}.{d(3) e(4)} z:a <:a"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            let a =  root.findPath("a"),
            let ab = a.findPath("b"),
            let ac = a.findPath("c"),
            let abd = ab.findPath("d"),
            let abe = ab.findPath("e"),
            let acd = ac.findPath("d"),
            let ace = ac.findPath("e"),

            let z =  root.findPath("z"),
            let zb = z.findPath("b"),
            let zc = z.findPath("c"),
            let zbd = zb.findPath("d"),
            let zbe = zb.findPath("e"),
            let zcd = zc.findPath("d"),
            let zce = zc.findPath("e") {

            ab.setVal(10, .activate)
            ac.setVal(20, .activate)
            abd.setVal(30, .activate)
            abe.setVal(40, .activate)
            acd.setVal(50, .activate)
            ace.setVal(50, .activate)

            let result1 =  root.dumpScript(indent: 0, session: false)
            let expect1 = """

            √ { a       { b(10)       { d(30)         e(40)         }
                          c(20)       { d(50)         e(50)         }}
                z:a <:a { b(10) <:a.b { d(30) <:a.b.d e(40) <:a.b.e }
                          c(20) <:a.c { d(50) <:a.c.d e(50) <:a.c.e }}}
            """
            err += ParStr.testCompare(expect1, result1)

            zb.setVal(11, .activate)
            zc.setVal(22, .activate)
            zbd.setVal(33, .activate)
            zbe.setVal(44, .activate)
            zcd.setVal(55, .activate)
            zce.setVal(66, .activate)

            let result2 =  root.dumpScript(indent: 0, session: false)
            let expect2 = """

            √ {  a      { b(10)       { d(30)         e(40)         }
                          c(20)       { d(50)         e(50)         }}
                z:a <:a { b(11) <:a.b { d(33) <:a.b.d e(44) <:a.b.e }
                          c(22) <:a.c { d(55) <:a.c.d e(66) <:a.c.e }}}
            """
            err += ParStr.testCompare(expect2, result2)

        } else {
            err += 1
        }
        XCTAssertEqual(err, 0)
    }

    /// test `z: a <:> a`
    func testCopyAtR2() { headline(#function)
        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a {b(1) c(2)}.{d(3) e(4)} z: a <:> a"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let ab = a.findPath("b"),
            let ac = a.findPath("c"),
            let abd = ab.findPath("d"),
            let abe = ab.findPath("e"),
            let acd = ac.findPath("d"),
            let ace = ac.findPath("e"),

            let z = root.findPath("z"),
            let zb = z.findPath("b"),
            let zc = z.findPath("c"),
            let zbd = zb.findPath("d"),
            let zbe = zb.findPath("e"),
            let zcd = zc.findPath("d"),
            let zce = zc.findPath("e") {

            ab.setVal(10, .activate)
            ac.setVal(20, .activate)
            abd.setVal(30, .activate)
            abe.setVal(40, .activate)
            acd.setVal(50, .activate)
            ace.setVal(60, .activate)

            let result1 =  root.dumpScript(indent: 0, session: false)
            let expect1 = """

            √ { a {        b(10)        { d(30)          e(40)          }
                           c(20)        { d(50)          e(60)          } }
                z:a <:>a { b(10) <:>a.b { d(30) <:>a.b.d e(40) <:>a.b.e }
                           c(20) <:>a.c { d(50) <:>a.c.d e(60) <:>a.c.e } } }
            """
            err += ParStr.testCompare(expect1, result1)

            zb.setVal(11, .activate)
            zc.setVal(22, .activate)
            zbd.setVal(33, .activate)
            zbe.setVal(44, .activate)
            zcd.setVal(55, .activate)
            zce.setVal(66, .activate)

            let result2 =  root.dumpScript(indent: 0, session: false)
            let expect2 = """

            √ { a        { b(11)        { d(33)          e(44)          }
                           c(22)        { d(55)          e(66)          } }
                z:a <:>a { b(11) <:>a.b { d(33) <:>a.b.d e(44) <:>a.b.e }
                           c(22) <:>a.c { d(55) <:>a.c.d e(66) <:>a.c.e } } }
            """
            err += ParStr.testCompare(expect2, result2)

        } else {
            err += 1
        }
        XCTAssertEqual(err, 0)
    }

    /// test `z: a <: a`
    func testFilter() { headline(#function)
        Par.trace = true
        var err = 0
        
        err += test("a (w == 0, x 1, y 0)")

        err += test("a (w 0, x 1, y 0)")

        err += test("a {b c}.{ d(1) e(2) }",
                    "√ { a { b { d(1) e(2) } c { d(1) e(2) } } }")

        err += test("a {b c}.{ d(x 1) e(y 2) }",
                    "√ { a { b { d(x 1) e(y 2) } c { d(x 1) e(y 2) } } }")

        err += test("a {b c}.{ d(x 1) e(y 2) } w(x 0, y 0, z 0)",
                    "√ { a { b { d (x 1) e (y 2) } " +
                    "        c { d (x 1) e (y 2) } } " +
                    "    w (x 0, y 0, z 0) }")

        err += test("a {b c}.{ d(x == 10, y 0, z 0) e(x 0, y == 21, z 0) }",
                    "√ { a { b { d (x == 10, y 0, z 0) e (x 0, y == 21, z 0) } " +
                    "        c { d (x == 10, y 0, z 0) e (x 0, y == 21, z 0) } } }")

        err += test("a {b c}.{ d(x == 10, y 0, z 0) e(x 0, y == 21, z  0) } w(x 0, y 0, z 0) <> a˚.",
                    "√ { a { b { d (x == 10, y 0, z 0) e (x 0, y == 21, z 0) } " +
                    "        c { d (x == 10, y 0, z 0) e (x 0, y == 21, z 0) } } " +
                    "    w (x 0, y 0, z 0) <>(a.b.d a.b.e a.c.d a.c.e) }")

        // selectively set tuples by name, ignore the reset
        let script = "a {b c}.{ d(x == 10, y 0, z 0) e(x 0, y == 21, z 0) } w(x 0, y 0, z 0) <> a˚."
        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            let w = root.findPath("w") {

            // 0, 0, 0 --------------------------------------------------
            let t0 = Tr3Exprs(pairs: [("x", 0), ("y", 0), ("z", 0)])
            w.setVal(t0, .activate)
            let result0 = root.dumpScript(indent: 0, session: true)
            let expect0 = """

            √ { a { b { d (x 0, y 0, z 0) e (x 0, y 0, z 0) }
                    c { d (x 0, y 0, z 0) e (x 0, y 0, z 0) } }
                        w (x 0, y 0, z 0) <> (a.b.d a.b.e a.c.d a.c.e) }
            """
            err += ParStr.testCompare(expect0, result0)

            // 10, 11, 12 --------------------------------------------------
            let t1 = Tr3Exprs(pairs: [("x", 10), ("y", 11), ("z", 12)])
            w.setVal(t1, .activate)
            let result1 = root.dumpScript(indent: 0, session: true)
            let expect1 = """

            √ { a { b { d (x 10, y 11, z 12) e (x 0, y 0, z 0) }
                    c { d (x 10, y 11, z 12) e (x 0, y 0, z 0) } }
                        w (x 10, y 11, z 12) <> (a.b.d a.b.e a.c.d a.c.e) }
            """
            err += ParStr.testCompare(expect1, result1)

            // 20, 21, 22 --------------------------------------------------
            let t2 = Tr3Exprs(pairs: [("x", 20), ("y", 21), ("z", 22)])
            w.setVal(t2, .activate)
            let result2 = root.dumpScript(indent: 0, session: true)
            let expect2 = """

            √ { a { b { d (x 10, y 11, z 12) e (x 20, y 21, z 22) }
                    c { d (x 10, y 11, z 12) e (x 20, y 21, z 22) } }
                        w (x 20, y 21, z 22) <> (a.b.d a.b.e a.c.d a.c.e) }
            """
            err += ParStr.testCompare(expect2, result2)

            // 10, 21, 33 --------------------------------------------------
            let t3 = Tr3Exprs(pairs: [("x", 10), ("y", 21), ("z", 33)])
            w.setVal(t3, .activate)
            let result3 = root.dumpScript(indent: 0, session: true)
            let expect3 = """

            √ { a { b { d (x 10, y 21, z 33) e (x 10, y 21, z 33) }
                    c { d (x 10, y 21, z 33) e (x 10, y 21, z 33) } }
                        w (x 10, y 21, z 33) <> (a.b.d a.b.e a.c.d a.c.e) }
            """
            err += ParStr.testCompare(expect3, result3)

        } else {
            err += 1
        }
        XCTAssertEqual(err, 0)
    }

    /// test `a(x 0) << c, b(y 0) << c, c(x 0, y 0)`
    func testExpr1() { headline(#function)

        var err = 0
        // selectively set tuples by name, ignore the reset
        let script = "a(x 0) << c, b(y 0) << c, c(x 0, y 0)"
        print("\n" + script)

        let root = Tr3("√")

        if tr3Parse.parseScript(root, script),
            let c = root.findPath("c") {
            let p = CGPoint(x: 1, y: 2)
            c.setVal(p, .activate)
            let result = root.dumpScript(indent: 0, session: true)
            let expect = "√ { a(x 1) << c, b(y 2) << c, c(x 1, y 2) }"
            err = ParStr.testCompare(expect, result, echo: true)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err, 0)
    }

    func testExpr2() { headline(#function)
        Par.trace = true
        Par.trace2 = false
        var err = 0

        let script = "a(x 0..2, y 0..2, z 99), b (x 0..2, y 0..2) << a"
        print("\n" + script)

        let p0 = CGPoint(x: 1, y: 1)
        var p1 = CGPoint.zero

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a") {
            a.addClosure { tr3, _ in
                p1 = tr3.CGPointVal() ?? .zero
                print("p0\(p0) => p1\(p1)")
            }
            a.setVal(p0, [.activate])

            let result0 = root.dumpScript(indent: 0, session: true)
            let expect0 = "√ { a(x 1, y 1, z 99), b(x 1, y 1) << a }"
            err += ParStr.testCompare(expect0, result0, echo: true)

            let result1 = root.dumpScript(indent: 0, session: false)
            let expect1 = "√ { a(x 0..2, y 0..2, z 99), b(x 0..2, y 0..2) << a }"
            err += ParStr.testCompare(expect1, result1, echo: true)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err, 0)
        XCTAssertEqual(p0, p1)
        Par.trace = false
        Par.trace2 = false
    }

    func testExpr3() { headline(#function)
        Par.trace = true
        Par.trace2 = false
        var err = 0

        let script = "a(x in 2..4, y in 3..5) >> b b(x 1..2, y 2..3)"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
           let a = root.findPath("a") {

            let result0 = root.dumpScript(indent: 0, session: false)
            let expect0 = "√ { a (x in 2..4, y in 3..5) >>b b (x 1..2, y 2..3) }"
            err += ParStr.testCompare(expect0, result0, echo: true)

            let p1 = CGPoint(x: 3, y: 4)
            a.setVal(p1, [.activate])

            let result1 = root.dumpScript(indent: 0, session: true)
            let expect1 = "√ { a(x 3, y 4) >>b b (x 1.5, y 2.5) }"
            err += ParStr.testCompare(expect1, result1, echo: true)

        } else {
            err += 1
        }
        XCTAssertEqual(err, 0)
        Par.trace = false
        Par.trace2 = false
    }

    func testPassthrough() { headline(#function)
        var err = 0
        let script = "a(0..1)<<b, b<<c, c(0..10)<<a"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let b = root.findPath("b"),
            let c = root.findPath("c") {

            a.addClosure { tr3, _ in self.addCallResult(a, tr3.val!) }
            b.addClosure { tr3, _ in self.addCallResult(b, tr3.val!) }
            c.addClosure { tr3, _ in self.addCallResult(c, tr3.val!) }

            err += testAct("c(5.0)", "c(5.0) b(5.0) a(0.5)") {
                c.setVal(5.0, .activate) }
            err += testAct("a(0.1)", "a(0.1) c(1.0) b(1.0) ") {
                a.setVal(0.1, .activate) }
            err += testAct("b(0.2)", "b(0.2) a(0.020000001) c(0.20000002)") {
                b.setVal(0.2, .activate) }
        }
        else {
            err += 1
        }
        XCTAssertEqual(err, 0)
    }

    func testTernary1() { headline(#function)
        var err  = 0
        let script = "a b c w(0) << (a ? 1 : b ? 2 : c ? 3)"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let b = root.findPath("b"),
            let c = root.findPath("c"),
            let w = root.findPath("w") {

            err += ParStr.testCompare("√ { a⋯>w b⋯>w c⋯>w w(0)<<(a ? 1 : b ? 2 : c ? 3) }", root.dumpScript(indent: 0, session: true), echo: true)

            w.addClosure { tr3, _ in self.addCallResult(w, tr3.val!) }
            err += testAct("a !",  "w(1.0) ") { a.activate() }
            err += testAct("a(0)", "w(1.0)")  { a.setVal(0, [.create,.activate]) }
            err += testAct("b !",  "w(2.0) ") { b.activate() }
            err += testAct("b(0)", "w(2.0)")  { b.setVal(0, [.create,.activate]) }
            err += testAct("c !",  "w(3.0) ") { c.activate() }

            err += ParStr.testCompare(" √ { a(0)⋯>w b(0)⋯>w c⋯>w w(3)<<(a ? 1 : b ? 2 : c ? 3) }", root.dumpScript(indent: 0, session: true), echo: true)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err, 0)
    }

    func testTernary2() { headline(#function)
        var err = 0
        let script = "a(0) x(10) y(20) w<<(a ? x : y)"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let x = root.findPath("x"),
            let y = root.findPath("y"),
            let w = root.findPath("w") {

            err += ParStr.testCompare("√ { a(0)⋯>w x(10)╌>w y(20)╌>w w<<(a ? x : y) }", root.dumpScript(indent: 0, session: true), echo: true)

            w.addClosure { tr3, _ in self.addCallResult(w, tr3.val!) }
            err += testAct("a(0)",  "w(20.0)")  { a.setVal(0,.activate) }
            err += testAct("x(11)", "")         { x.setVal(11,.activate) }
            err += testAct("y(21)", "w(21.0)")  { y.setVal(21,.activate) }
            err += testAct("a(1)",  "w(11.0)")  { a.setVal(1,.activate) }
            err += testAct("x(12)", "w(12.0)")  { x.setVal(12,.activate) }
            err += testAct("y(22)", "")         { y.setVal(22,.activate) }

            err += testAct("a(0)", "w(22.0)")  { a.setVal(0,.activate) }
            err += ParStr.testCompare("√ { a(0)⋯>w x(12)╌>w y(22)>>w w(y)<<(a ? x : y) }", root.dumpScript(indent: 0, session: true), echo: true)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err, 0)
    }

    func testTernary3() { headline(#function)
        var err = 0
        let script = "a x(10) y(20) w<>(a ? x : y)"
        print("\n" + script)

        let root = Tr3("√")
        if tr3Parse.parseScript(root, script),
            let a = root.findPath("a"),
            let x = root.findPath("x"),
            let y = root.findPath("y"),
            let w = root.findPath("w") {

            err += ParStr.testCompare("√ { a⋯>w x(10)<╌>w y(20)<╌>w w<>(a ? x : y) }", root.dumpScript(indent: 0, session: true), echo: true)

            w.addClosure { tr3, _ in self.addCallResult(w, tr3.val!) }
            x.addClosure { tr3, _ in self.addCallResult(x, tr3.val!) }
            y.addClosure { tr3, _ in self.addCallResult(y, tr3.val!) }
            err += testAct("a(0)", "w(20.0) y(20.0)") { a.setVal(0, [.create,.activate]) }
            err += testAct("w(3)", "w(3.0)  y(3.0)")  { w.setVal(3, [.create,.activate]) }
            err += testAct("a(1)", "w(3.0)  x(3.0)")  { a.setVal(1,.activate) }
            err += testAct("w(4)", "w(4.0)  x(4.0)")  { w.setVal(4, [.activate]) }

            err += ParStr.testCompare("√ { a(1)⋯>w x(4)<>w y(3)<╌>w w(4)<>(a ? x : y) }", root.dumpScript(indent: 0, session: true), echo: true)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err, 0)
    }

    func testEdges() { headline(#function)
        var err = 0
        let root = Tr3("√")
        //let script = "x.xx y.yy a.b c: a { d << (x ? x.xx | y ? y.yy) } e: c f: e g: f"
        //let script = "x.xx y.yy a.b c: a e: c f: e g: f ˚b << (x ? x.xx | y ? y.yy) "
        //let script = "x.xx y.yy a { b << (x ? x.xx | y ? y.yy) } c: a, e: c, f: e, g: f "
        let script = "a.b.c(1) d { e(2) <> a.b.c } f: d"

        if tr3Parse.parseScript(root, script, whitespace: "\n\t ") {

            let pretty = root.makeScript(indent: 0, pretty: true)
            print(pretty)

            let d3Script = root.makeD3Script()
            print(d3Script)
        }
        else {
            err += 1
        }
        XCTAssertEqual(err, 0)
    }


    /// test Avatar and Robot definitions
    func testBodySkeleton() { headline(#function)

        var err = 0
        err += testFile("test.avatar.input", out: "test.avatar.output")
        err += testFile("test.robot.input",  out: "test.robot.output")
        //Tr3Log.dump()
        XCTAssertEqual(err, 0)
    }


    func testDeepMenu() { headline(#function)
        var err = 0
        err += test(
        """
        menu {
            canvas (title "canvas", type "node", icon "icon.drop.clear") {
                fill (title "fill", type "node", icon "icon.speed.png") {
                    plane (title "Bit Plane", type "slider", value 0..1)
                    zero  (title "Fill Zero", type "pad"   , value 0..1, icon "icon.drop.clear") // fillZero
                    one   (title "Fill Ones", type "pad"   , value 0..1, icon "icon.drop.gray") // fillOne
                }
                tile (title "tile", type "node", icon "icon.shader.tile.png") {
                    mirror (title "Mirror", type "rectXY", x 0..1, y 0..1, icon "icon.pearl.white.png") // mirrorBox
                    repeat (title "Repeat", type "rectXY", x 0..1, y 0..1, icon "icon.pearl.white.png") // repeatBox
                }
                scroll (title "scroll", type "node", icon "icon.cell.scroll.png") {
                    box  (title "Screen Scroll", type "rectXY", x 0..1, y 0..1, icon "icon.cell.scroll.png") // scrollBox
                    tilt (title "Brush Tilt"   , type "toggle", value 0..1, icon "icon.pen.tilt.png") // brushTilt
                }
                color(title "color", type "node", icon "icon.pal.main.png") {
                    fade (title "Screen Scroll", type "rectXY", x 0..1, y 0..1 , icon "icon.scroll.png") // scrollBox
                    tilt (title "Brush Tilt"   , type "toggle", value 0..1, icon "icon.pen.tilt.png") // brushTilt
                }
            }
            speed (title "speed", type "node", icon "icon.speed.png") {
                fps   (title "fps"  , type "slider", value 0..1, icon "icon.speed.png")
                pause (title "pause", type "toggle", value 0..1, icon "icon.thumb.x.png")
            }
            brush (title "brush", type "node", icon "icon.cell.brush.png") {
                size  (title "brush size", type "slider", value 0..1, icon "icon.pen.press.png") // brushSize
                press (title "pen press" , type "toggle", value 0..1, icon "icon.pen.press.png") // brushPress
                tilt  (title "pen title", type "toggle", value 0..1, icon "icon.pen.tilt.png") // brushPress
            }
            cell (title "cell", type "node") {
                fade  (title "fade away"   , type "slider" , value 0..1, icon "icon.cell.fader")
                ave   (title "average"     , type "slider" , value 0..1, icon "icon.cell.average")
                melt  (title "reaction"    , type "slider" , value 0..1, icon "icon.cell.melt")
                tunl  (title "time tunnel" , type "segment", value 0..5, icon "icon.cell.time")
                zha   (title "zhabatinski" , type "segment", value 0..6, icon "icon.cell.zhabatinski")
                slide (title "slide planes", type "segment", value 0..7, icon "icon.cell.slide.png")
                fred  (title "fredkin"     , type "segment", value 0..4, icon "icon.cell.fredkin.png")
            }
            camera (title "camera", type "node", icon "icon.camera.png") {
                fake (title "false color", type "toggle", value 0..1, icon "icon.camera.png")
                real (title "real color" , type "toggle", value 0..1, icon "icon.camera.png")
                face (title "facing"     , type "toggle", value 0..1, icon "icon.camera.flip.png") >> sky.shader.cellCamera.flip
                xfade(title "cross fade" , type "slider", value 0..1, icon "icon.pearl.white.png")
                snap (title "snapshot"   , type "pad"   , value 0..1, icon "icon.camera.png")
            }
        }
        """)
        XCTAssertEqual(err, 0)
    }


    /// test snapshot of `Deep Muse` app
    func testDeepMuse() { headline(#function)

        let root = Tr3("√")
        func parse(_ name: String) -> Int { return self.parse(name, root) }
        var err = 0
        err += parse("sky.main")
        err += parse("sky.midi")
        err += parse("sky.shader")
        err += parse("panel.cell")
        err += parse("panel.cell.average")
        err += parse("panel.cell.brush")
        err += parse("panel.cell.camera")
        err += parse("panel.cell.drift")
        err += parse("panel.cell.fader")
        err += parse("panel.cell.fredkin")
        err += parse("panel.cell.gas")
        err += parse("panel.cell.melt")
        err += parse("panel.cell.midi")
        err += parse("panel.cell.modulo")
        err += parse("panel.record")
        err += parse("panel.cell.scroll")
        err += parse("panel.cell.slide")
        err += parse("panel.cell.speed")
        err += parse("panel.cell.timeTunnel")
        err += parse("panel.cell.zhabatinski")
        err += parse("panel.shader.colorize")
        err += parse("panel.shader.tile")
        err += parse("panel.shader.weave")

        let actual = root.dumpScript(indent: 0)
        let expect = read("test.sky.output") ?? ""
        err += ParStr.testCompare(expect, actual)

        XCTAssertEqual(err, 0)
    }

    static var allTests = [

        ("testParseShort", testParseShort),
        ("testParseBasics", testParseBasics),
        ("testParsePathCopy", testParsePathCopy),
        ("testParsePaths", testParsePaths),
        ("testParseValues", testParseValues),
        ("testParseEdges", testParseEdges),
        ("testParseTernarys", testParseTernarys),
        ("testParseRelativePaths", testParseRelativePaths),
        ("testParseRelativePaths", testParseRelativePaths),

        ("testEdgeVal", testEdgeVal),
        ("testEdgeVal2", testEdgeVal2),
        ("testEdgeVal3a", testEdgeVal3a),
        ("testEdgeVal3b", testEdgeVal3b),
        ("testEdgeVal4", testEdgeVal4),

        ("testCopyAtR1", testCopyAtR1),
        ("testCopyAtR2", testCopyAtR2),
        ("testExpr1", testExpr1),
        ("testExpr2", testExpr2),
        ("testExpr3", testExpr3),
        ("testPassthrough", testPassthrough),
        ("testTernary1", testTernary1),
        ("testTernary2", testTernary2),
        ("testTernary3", testTernary3),
        ("testEdges", testEdges),

        ("testBodySkeleton", testBodySkeleton),
        ("testDeepMenu", testDeepMenu),
        ("testDeepMuse", testDeepMuse),
    ]
}
