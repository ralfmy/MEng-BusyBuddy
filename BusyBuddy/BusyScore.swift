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
    
    enum Score: String {
        case none = "NONE"
        case notbusy = "NOT BUSY"
        case busy = "BUSY"
        case unsure = "NOT CONFIDENT"
    }
    
    var image: UIImage
    var score: Score = .none
    var date: Date
    
    let expiry: Double = 2 * 60
    
    // count = -1 means loading; count = -2 means no result
    
    init(score: Score = .none, image: UIImage = UIImage(), date: Date = Date()) {
        self.score = score
        self.image = image
        self.date = date
    }
    
    public func scoreAsString() -> String {
        if self.score == .none {
            return "LOADING"
        }
        return self.score.rawValue
    }
    
    public func dateAsString() -> String {
        GlobalDateFormatter.dateFormatter.timeStyle = .short
        let dateString = GlobalDateFormatter.dateFormatter.string(from: self.date)
        return dateString
    }
    
    public func isExpired() -> Bool {
        if self.date.addingTimeInterval(expiry) < Date() {
            return true
        } else {
            return false
        }
    }
}


struct GlobalDateFormatter {
    static let dateFormatter = DateFormatter()
}
