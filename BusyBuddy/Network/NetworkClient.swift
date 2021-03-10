//
//  NetworkClient.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 22/12/2020.
//
//  With help from:
//  https://www.oliverbinns.co.uk/2020/06/27/create-a-tube-status-home-screen-widget-for-ios-14/

import Foundation

public class NetworkClient {
    private let session: URLSession
    
    enum NetworkError: Error {
        case noData
    }
    
    init() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    public func runRequest(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        self.session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
}
