//
//  FavouriteDetail.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI
import os.log

struct FavouriteDetail: View {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "FavouriteDetail")
    
    @EnvironmentObject var favouritesManager: FavouritesManager
    @EnvironmentObject var imageCache: ImageCache

    @State private var cacheTimer: Timer?
    @State private var modelTimer: Timer?
    @State private var buttonState: Int = 1
    @State private var buttonColor: Color = Color.red
    @State private var scoreText = ""
    
    let place: CodablePlace
    @Binding var busyScores: [BusyScore]
    
    var body: some View {
        VStack {
            Text(scoreText)
            Spacer()
            Button(buttonState == 0 ? "Add to Favourites" : "Remove from Favourites") {
                if favouritesManager.contains(place: self.place) {
                    favouritesManager.remove(place: self.place)
                    self.buttonState = 0
                    self.buttonColor = Color.blue
                } else {
                    favouritesManager.add(place: self.place)
                    self.buttonState = 1
                    self.buttonColor = Color.red

                }
            }.foregroundColor(buttonColor)
            .navigationBarTitle(self.place.commonName)
            .navigationBarItems(trailing: Button(action: {
                updateScore()
            }) {
                Image(systemName: "arrow.clockwise.circle.fill").imageScale(.large).frame(width: 64, height: 64, alignment: .trailing)
            })
        }.onAppear {
            updateScoreText(with: self.busyScores.first(where: { $0.id == place.id })!)
        }
//        .onAppear {
//            if favouritesManager.contains(place: self.place) {
//                self.buttonState = 1
//            } else {
//                self.buttonState = 0
//            }
//            var images = self.imageCache.getImages(forKey: place.id)
//            self.cacheTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//                if images != nil {
//                    updateScore()
//                    cacheTimer!.invalidate()
//                    self.logger.info("INFO: CACHE TIMER INVALIDATED.")
//                } else {
//                    images = self.imageCache.getImages(forKey: place.id)
//                }
//            }
//
//        }.onDisappear {
//            modelTimer?.invalidate()
//            self.logger.info("INFO: MODEL TIMER INVALIDATED.")
//        }
    }
    
    func updateScore() {
        let busyScore = ML.model.run(on: [self.place]).first!
        self.busyScores[self.busyScores.firstIndex(where: { $0.id == self.place.id })!] = busyScore
        updateScoreText(with: busyScore)
    }
    
    func updateScoreText(with busyScore: BusyScore) {
        if busyScore.score == .none {
            self.logger.debug("DEBUG: No objects detected.")
            self.scoreText = "No Objects Detected"
        } else {
            self.scoreText = "\(busyScore.score)\n\(busyScore.count)"
        }
        
    }
}

struct FavouriteDetail_Previews: PreviewProvider {
    @State static private var busyScores = [BusyScore(id: "id", count: 5)]
    
    static var previews: some View {
        FavouriteDetail(place: PlaceExample.place, busyScores: $busyScores)
    }
}
