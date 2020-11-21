import XCTest

import postgreshelperTests

var tests = [XCTestCaseEntry]()
tests += postgreshelperTests.allTests()
XCTMain(tests)
