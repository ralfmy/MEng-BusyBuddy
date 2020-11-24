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
    
    @State private var buttonState: Int = 1
    @State private var buttonColor: Color = Color.red
    @State private var scoreText = ""
    
    let place: Place
    
    var body: some View {
        VStack {
            PlaceMap(place: self.place)
            Spacer()
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
            updateScoreText()
        }
    }
    
    func updateScore() {
        self.scoreText = "Loading..."
        self.favouritesManager.updateBusyScoreFor(place: self.place)
        updateScoreText()
    }
    
    func updateScoreText() {
        let busyScore = self.place.busyScore
        if busyScore.score == .none {
            self.logger.debug("DEBUG: No objects detected.")
            self.scoreText = "No Objects Detected"
        } else {
            self.scoreText = "\(busyScore.score)\n\(busyScore.count)"
        }
    }
}

struct FavouriteDetail_Previews: PreviewProvider {
    @State static private var busyScores = [BusyScore(count: 5)]
    
    static var previews: some View {
        FavouriteDetail(place: PlaceExample.place)
    }
}
