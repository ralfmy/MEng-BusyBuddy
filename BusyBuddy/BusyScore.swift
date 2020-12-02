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

struct BusyScore {
    
    enum Score {
        case none
        case low
        case medium
        case high
    }
    
    var id: String
    var count: Int
    var score: Score = .none
    var date: Date
    
    let expiry: Double = 5 * 60
    
    // count = -1 means loading; count = -2 means no result
    
    init(id: String, count: Int = -1, date: Date = Date()) {
        self.id = id
        self.count = count
        self.date = date
        switch self.count {
        case 0..<5:
            self.score = .low
        case 5..<10:
            self.score = .medium
        case 10...:
            self.score = .high
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
            return "NO OBJECTS DETECTED"
        case .low:
            return "NOT BUSY"
        case .medium:
            return "FAIRLY BUSY"
        case .high:
            return "VERY BUSY"
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
