//
//  FunTests.swift
//  FunTests
//
//  Created by Jake Rein on 12/19/18.
//  Copyright © 2018 Jake Rein. All rights reserved.
//

import XCTest
@testable import Fun

class FunTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let s = ShowApi(source: Source.LIVE_ACTION).showList
        let rando = s[0]//.randomElement()!
        track("\(rando.name) with \(rando.url)")
        let a = EpisodeApi(url: rando.url)
        let z = a.episodeList[0]
        track("\(z.getVideo())")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
