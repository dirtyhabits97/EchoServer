import XCTest

import EchoSocketServerTests

var tests = [XCTestCaseEntry]()
tests += EchoSocketServerTests.allTests()
XCTMain(tests)
