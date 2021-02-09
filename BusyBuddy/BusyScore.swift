//
//  Busyness.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 07/11/2020.
//
//  With help from
//  https://www.hackingwithswift.com/example-code/uikit/how-to-load-a-remote-image-url-into-uiimageview

import Foundation
import UIKit

public final class BusyScore {
    
    enum Score {
        case none
        case low
        case medium
        case high
        case unsure
    }
    
    var count: Int
    var image: UIImage
    var score: Score = .none
    var date: Date
    
    let expiry: Double = 0 * 60
    
    // count = -1 means loading; count = -2 means no result
    
    init(count: Int = -1, image: UIImage = UIImage(), date: Date = Date()) {
        self.count = count
        self.image = image
        self.date = date
        switch self.count {
        case 0..<10:
            self.score = .low
        case 10..<15:
            self.score = .medium
        case 15...:
            self.score = .high
        case -2:
            self.score = .unsure
        default:
            self.score = .none
        }
    }
    
    public func scoreAsString() -> String {
        if self.count == -1 {
            return "LOADING"
        }
        switch self.score {
        case .none:
            return "NONE"
        case .low:
            return "NOT BUSY"
        case .medium:
            return "FAIRLY BUSY"
        case .high:
            return "BUSY"
        case.unsure:
            return "NOT CONFIDENT"
        default:
            return "ERROR"
        }
    }
    
    public func dateAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self.date)
    }
    
    public func isExpired() -> Bool {
        if self.date.addingTimeInterval(expiry) < Date() {
            return true
        } else {
            return false
        }
    }
}
