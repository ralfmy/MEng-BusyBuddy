//
//  ImageLoader.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/12/2020.
//

import Foundation
import UIKit
import os.log

public struct ImageLoader {
    static let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "ImageLoader")
    
    public static func loadImageFrom(url: String, client: NetworkClient, completion: ((UIImage) -> Void)? = nil) {
        guard let url = URL(string: url) else { return }
        self.logger.info("INFO: HERE")

        client.runRequest(request: URLRequest(url: url)) { result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    self.logger.info("INFO: UIImage loaded.")
                    completion?(image)
                } else {
                    self.logger.error("ERROR: Cannot load image.")
                }
            case .failure(let error):
                self.logger.error("ERROR: \(error.localizedDescription)")
            }
        }
    }
}
