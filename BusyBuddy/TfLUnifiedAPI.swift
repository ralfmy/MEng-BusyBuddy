//
//  TfLUnifiedAPI.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 31/10/2020.
//

import Foundation
import UIKit
import os.log

//  Methods for calling the TfL Unified API.
public struct TfLUnifiedAPI {
    
    public static func fetchAllJamCams(client: NetworkClient, completion: (([Place]) -> Void)? = nil) {
        let prefix = "https://api.tfl.gov.uk/"
        let api_key = Bundle.main.object(forInfoDictionaryKey: "TfLApiKey") as! String
        
        guard let url = URL(string: prefix + "Place/Type/JamCam?app_key=" + api_key) else { return }
        
        client.runRequest(request: URLRequest(url: url)) { result in
            switch result {
            case .success(let data):
                do {
                    let places = try JSONDecoder().decode([Place].self, from: data)
                    completion?(places)
                } catch {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}
