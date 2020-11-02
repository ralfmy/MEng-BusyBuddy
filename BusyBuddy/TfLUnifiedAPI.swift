//
//  TfLUnifiedAPI.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 31/10/2020.
//

import Foundation
import UIKit

//  Methods for calling the TfL Unified API.

struct TfLUnifiedAPI {
    
    private let session: URLSession
    
    let prefix = "https://api.tfl.gov.uk/"
    let api_key = ProcessInfo.processInfo.environment["api_key"]
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchAllJamCams(completion: @escaping (Result<[Place], Error>) -> Void) {
        guard let url = URL(string: self.prefix + "Place/Type/JamCam?app_key=" + self.api_key!) else { return }
        
        session.dataTask(with: url) { (data, response, error) in
            if let err = error {
                completion(.failure(err))
            }
                        
            do {
                let places = try JSONDecoder().decode([Place].self, from: data!)
                completion(.success(places))
            } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    }
}
