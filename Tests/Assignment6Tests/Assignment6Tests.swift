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

    static var allTests = [
        ("testInitNumC", testInitNumC),
        ("testInitStrC", testInitStrC),
    ]
}
