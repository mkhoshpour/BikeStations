//
//  NetworkHelper.swift
//  BikeStations
//
//  Created by Majid on 5/18/18.
//  Copyright © 2018 FinCup. All rights reserved.
//

import UIKit

struct HTTPClientEndPoint  {
    let method : HTTPMethod
    let path : String
    let body : Data?
}

struct HTTPRequestResult {
    let result : [BikeStation]?
    let error : Error?
}



enum HTTPMethod : String {
    case get = "GET"
    case post = "POST"
}


class NetworkHTTPClient {
    static func performRequest(_ endpoint: HTTPClientEndPoint,result : @escaping (HTTPRequestResult) -> ()) {
        var request = URLRequest(url: URL(string: "https://data.melbourne.vic.gov.au/resource/whrp-vp44.json" + endpoint.path)!)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if((error) == nil){
                let decoder = JSONDecoder()
                if let decode = try? decoder.decode([BikeStation].self, from: data!) {
                    result(HTTPRequestResult(result: decode, error: nil))
                }
            }else{
                result(HTTPRequestResult(result: nil, error: error))
            }
        }
        dataTask.resume()
        
    }
}
