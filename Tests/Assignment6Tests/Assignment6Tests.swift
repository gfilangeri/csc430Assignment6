import XCTest
@testable import Assignment6

final class Assignment6Tests: XCTestCase {
    func testInitNumC() {
        let n = NumC(num: 1)
        XCTAssertEqual(n.num, 1)
    }

    func testInitStrC() {
        let s = StrC(str: "hi")
        XCTAssertEqual(s.str, "hi")
    }
    
    func testInitIdC() {
        let id = IdC(id: "hi")
        XCTAssertEqual(id.id, "hi")
    }
    
    func testInitAppC() {
        let app = AppC(fn: NumC(num: 1), args: [NumC(num: 1)])
        XCTAssertEqual((app.fn as! NumC).num, 1)
    }
    
    func testInitIfC() {
        let f = IfC(ifStmnt: NumC(num: 1), thenStmnt: NumC(num: 1), elseStmnt: NumC(num: 2))
        XCTAssertEqual(((f.ifStmnt as! NumC).num == 1) && ((f.thenStmnt as! NumC).num == 1), true)
    }
    
    func testInitLamC() {
        let l = LamC(param: [NumC(num: 1)], body: NumC(num: 1))
        XCTAssertEqual((l.param[0] as! NumC).num, 1)
    }

    func testInitNumV() {
        let n = NumV(num: 1)
       XCTAssertEqual(n.num, 1)
    }
    
    func testInitStrV() {
        let s = StrV(str: "hi")
       XCTAssertEqual(s.str, "hi")
    }
    
    func testInitCloV() {
        let c = CloV(param: [IdC(id: "hi")], body: NumC(num: 1), cloEnv: Env(list: []))
       XCTAssertEqual(((c.param[0].id == "hi") && ((c.body as! NumC).num == 1)), true)
    }
    
    func testInitBoolV() {
        let b = BoolV(b: true)
       XCTAssertEqual(b.b, true)
    }
    
    func testInitPrimV() {
        func testPrimFunc (vals: [Value]) -> Value {
            return vals[0]
        }
        let p = PrimV(fn: testPrimFunc)
       XCTAssertEqual((p.fn([NumV(num: 1)]) as! NumV).num, 1)
    }

    static var allTests = [
        ("testInitNumC", testInitNumC),
        ("testInitStrC", testInitStrC),
        ("testInitIdC", testInitIdC),
        ("testInitAppC", testInitAppC),
        ("testInitIfC", testInitIfC),
        ("testInitLamC", testInitLamC),
        ("testInitNumV", testInitNumV),
        ("testInitStrV", testInitStrV),
        ("testInitCloV", testInitCloV),
        ("testInitBoolV", testInitBoolV),
        ("testInitPrimV", testInitPrimV)
    ]
}
