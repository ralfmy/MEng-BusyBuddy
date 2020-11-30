//
//  BusyScoreCache.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 17/11/2020.
//
//
//import Foundation
//import os.log
//
//class BusyScoreCache: ObservableObject {
//    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "BusyScoreCache")
//
//    @Published private var cache = NSCache<NSString, BusyScoreCacheEntry>()
//}
//
//class BusyScoreCacheEntry {
//    var date: Date
//    var busyScore: BusyScore
//    
//    init(date: Date = Date(), busyScore: BusyScore = BusyScore()) {
//        self.date = date
//        self.busyScore = busyScore
//    }
//}
