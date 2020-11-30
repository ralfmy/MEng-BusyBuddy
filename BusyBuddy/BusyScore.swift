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
    
    let outdate: Double = 5 * 60
    
    init(id: String, count: Int = -1) {
        self.id = id
        self.count = count
        self.date = Date()
        switch self.count {
        case 0..<5:
            self.score = .low
        case 5..<10:
            self.score = .medium
        case 10...:
            self.score = .high
        default:
            break
        }
    }
    
    public func scoreAsString() -> String {
        switch self.score {
        case .none:
            return "NONE"
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
    
    public func isStale() -> Bool {
        if self.date.addingTimeInterval(outdate) < Date() {
            return true
        } else {
            return false
        }
    }
}
