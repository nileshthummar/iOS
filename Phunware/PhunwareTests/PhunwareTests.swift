//
//  PhunwareTests.swift
//  PhunwareTests
//
//  Created by Nilesh on 6/16/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import XCTest
@testable import Phunware

class PhunwareTests: XCTestCase {

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
        var dt = "2015-06-18T23:30:00.000Z"
        var newdt = Utils.format(date: dt)
        XCTAssertEqual(newdt, "Thu, 18 Jun 2015 23:30 PM")
        dt = ""
        newdt = Utils.format(date: dt)
        XCTAssertEqual(newdt, "")
    }
    func testFetchData() {
        PersonAPI.shared.allPersonsAsync { (result) in
            switch result {
            case .success(let persons):
                XCTAssertNotNil(persons)
            case .error(let error):
                XCTAssertNil(error)
            }
        }
    }
}
