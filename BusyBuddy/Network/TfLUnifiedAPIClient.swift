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
public struct TfLUnifiedAPIClient {
    static let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "TfLUnifiedAPI")
    
    public static func fetchAllJamCams(client: NetworkClient, completion: (([JamCam]) -> Void)? = nil) {
        // Build TfL Unified API endpoint URL
        let endpoint = "https://api.tfl.gov.uk/Place/Type/JamCam?app_key="
        let api_key = Bundle.main.object(forInfoDictionaryKey: "TfLApiKey") as! String
        guard let url = URL(string: endpoint + api_key) else { return }
        
        let request = URLRequest(url: url)
                
        // Fetch data from endpoint
        client.runRequest(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let jamCams = try JSONDecoder().decode([JamCam].self, from: data)
                    completion?(jamCams)
                } catch {
                    self.logger.error("ERROR: \(error.localizedDescription)")
                }
            case .failure(let error):
                self.logger.error("ERROR: \(error.localizedDescription)")
            }
        }
    }
}
