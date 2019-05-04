//
//  BikeStation.swift
//  BikeStations
//
//  Created by Majid on 5/18/18.
//  Copyright © 2018 FinCup. All rights reserved.
//

import Foundation

struct BikeStation : Codable {
    let geocoded_column : Coordinate
//    let featurename : String
    let station_id : String
    let capacity : String
//    let nbemptydoc : String
    let name : String
//    let uploaddate : String
}


struct Visit : Decodable {
    let x : X
    let y : Y
    let z : Z

}



struct X : Decodable {
    let w : String
    
}

struct Y : Decodable {
    let w : String
    
}


struct Z : Decodable {
    let w : String?
    
}

func A () {
    for btnIndex in 0...3 {
        
    }
}
