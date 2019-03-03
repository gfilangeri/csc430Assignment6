import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Assignment6Tests.allTests),
    ]
}
#endif