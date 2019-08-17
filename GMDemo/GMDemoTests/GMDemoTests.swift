//
//  GMDemoTests.swift
//  GMDemoTests
//
//  Created by Nilesh on 8/8/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import XCTest
@testable import GMDemo

class GMDemoTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    func testDateFormat() {
        var dt = "2019-06-10T01:53:42Z"
        var newdt = Date.format(date: dt)
        XCTAssertEqual(newdt, "Mon, 10 Jun 2019 01:53 AM")
        dt = ""
        newdt = Date.format(date: dt)
        XCTAssertEqual(newdt, "")
    }    
}
