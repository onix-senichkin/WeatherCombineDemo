//
//  Network.swift
//  WeatherCombineDemo
//
//  Created by Denis Senichkin on 04.11.2020.
//

import Foundation
import Combine

protocol NetworkProtocol: class {
    typealias Headers = [String: Any]
    
    func get<T>(type: T.Type, url: URL) -> AnyPublisher<T, Error> where T: Decodable
}

final class Network: NetworkProtocol {
    
    func get<T: Decodable>(type: T.Type, url: URL) -> AnyPublisher<T, Error> {
        
        let urlRequest = URLRequest(url: url)
        
        //mockups
        /*if let dataUrl = Bundle.main.url(forResource: "Users", withExtension: "json"), let data = try? Data(contentsOf: dataUrl), let items = try? JSONDecoder().decode(T.self, from: data) {
            return Result<T, Error>.Publisher(items).eraseToAnyPublisher()
        }*/

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            //.map(\.data)
            .tryMap() { element -> Data in
                let resp = String(data: element.data, encoding: .utf8) ?? "n/a"
                print("dataTaskPublisher \(resp)")
                return element.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
