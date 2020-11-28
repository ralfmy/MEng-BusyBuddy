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
        ZStack {
            VStack {
                PlaceMap(place: place).edgesIgnoringSafeArea(.all)
                Spacer()
                Text(scoreText)
                Spacer()
                FavButton
            }
            
        }
        .navigationBarItems(trailing: UpdateButton).onAppear {
            updateScore()
        }
    }
    
    init(place: Place) {
        self.place = place

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().barTintColor = .clear
    }
    
    private var UpdateButton: some View {
        Button(action: {
            updateScore()
        }) {
            Image(systemName: "arrow.clockwise.circle.fill").imageScale(.large).frame(width: 64, height: 64, alignment: .trailing)
        }
    }
    
    private var FavButton: some View {
        Button(buttonState == 0 ? "Add to Favourites" : "Remove from Favourites") {
            if favouritesManager.contains(place: place) {
                favouritesManager.remove(place: place)
                buttonState = 0
                buttonColor = Color.blue
            } else {
                favouritesManager.add(place: place)
                buttonState = 1
                buttonColor = Color.red

            }
        }.foregroundColor(buttonColor)
    }
    
    
    private func updateScore() {
        scoreText = "Loading..."
        DispatchQueue.main.async {
            if place.busyScoreNeedsUpdate() {
                ML.model.run(on: [place])
            }
            updateScoreText()
        }
    }
    
    private func updateScoreText() {
        let busyScore = place.busyScore
        if busyScore.score == .none {
            scoreText = "No Objects Detected"
        } else {
            scoreText = "\(busyScore.score)\n\(busyScore.count)"
        }
        
    }
}

struct PlaceDetail_Previews: PreviewProvider {
    static var previews: some View {
        PlaceDetail(place: ExamplePlace.place)
    }
}
