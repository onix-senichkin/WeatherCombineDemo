//
//  Endpoint.swift
//  WeatherCombineDemo
//
//  Created by Denis Senichkin on 04.11.2020.
//

import Foundation

private let kAppID: String = "ca0e7c8ded3dc110c23700789d307ab9"

struct Endpoint {
    let path: String
    var queryItems: [URLQueryItem] = []
}

extension Endpoint {
    
    var url: URL {
        var query = queryItems
        query.append(URLQueryItem(name: "appid", value: kAppID)) // add app id once
        query.append(URLQueryItem(name: "units", value: "metric"))
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/" + path
        components.queryItems = query
        
        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        
        return url
    }
}

extension Endpoint {
    
    static func weather(city: String) -> Self {
        return Endpoint(path: "weather", queryItems: [URLQueryItem(name: "q", value: city)])
    }
    
    static func forecast(city: String) -> Self {
        return Endpoint(path: "forecast/daily", queryItems: [URLQueryItem(name: "q", value: city)])
    }
}
