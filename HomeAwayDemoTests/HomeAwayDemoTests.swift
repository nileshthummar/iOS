//
//  HomeAwayDemoTests.swift
//  HomeAwayDemoTests
//
//  Created by Nilesh on 6/2/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import XCTest
@testable import HomeAwayDemo

class HomeAwayDemoTests: XCTestCase {

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
        var dt = "2019-06-02T19:30:00"
        var newdt = Utils.format(date: dt)
        XCTAssertEqual(newdt, "Sun, 2 Jun 2019 19:30 PM")
        dt = ""
        newdt = Utils.format(date: dt)
        XCTAssertEqual(newdt, "")
    }
    func testFetchEvents() {
        let eventsClient = EventsClient()
        let searchText = "Texas Ranger"
        eventsClient.fetchEvents(searchText: searchText) {(events, err) in
            XCTAssertNotNil(events)
        }
    }
}
