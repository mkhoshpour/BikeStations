//
//  BikeStationsTests.swift
//  BikeStationsTests
//
//  Created by Majid on 5/18/18.
//  Copyright © 2018 FinCup. All rights reserved.
//

import XCTest
@testable import BikeStations

class BikeStationsTests: XCTestCase {
    
    let masterVC = MasterViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testmakeCircle() {
        let image = masterVC.makeCircle(size: 10)
        XCTAssert(image.size == CGSize(width: 105, height: 105))
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
