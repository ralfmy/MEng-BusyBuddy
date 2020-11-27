//
//  PlaceDetail.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct PlaceDetail: View {
    @EnvironmentObject var favouritesManager: FavouritesManager

    @State private var buttonState: Int = 0
    @State private var buttonColor: Color = Color.blue
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
            updateScore()
        }
    }
    
    func updateScore() {
        self.scoreText = "Loading..."
        DispatchQueue.main.async {
            if place.busyScoreNeedsUpdate() {
                ML.model.run(on: [place])
            }
            updateScoreText()
        }
    }
    
    func updateScoreText() {
        let busyScore = self.place.busyScore
        if busyScore.score == .none {
            self.scoreText = "No Objects Detected"
        } else {
            self.scoreText = "\(busyScore.score)\n\(busyScore.count)"
        }
        
    }
}

struct PlaceDetail_Previews: PreviewProvider {
    static var previews: some View {
        PlaceDetail(place: PlaceExample.place)
    }
}
