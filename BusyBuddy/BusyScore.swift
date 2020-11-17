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
    
    init(id: String, count: Int) {
        self.id = id
        self.count = count
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
    
}
