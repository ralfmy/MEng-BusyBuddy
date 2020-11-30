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
    @State private var busyScore: BusyScore = BusyScore(id: "")
    @State private var scoreText = ""
    
    let place: Place
    
    var body: some View {
        ZStack {
            VStack {
                PlaceMap(place: place).edgesIgnoringSafeArea(.all)
                Spacer().frame(height: 20)
                BusyIcon(busyScore: busyScore, size: 100)
                Text(scoreText)
                Spacer()
                FavButton
                Spacer()
            }
            
        }
        .navigationBarItems(trailing: UpdateButton)
        .onAppear {
            updateScore()
            if favouritesManager.contains(place: place) {
                buttonState = 1
                buttonColor = Color.red
            } else {
                buttonState = 0
                buttonColor = Color.blue
            }
        }
    }

    private var UpdateButton: some View {
        Button(action: {
            updateScore()
        }) {
            Image(systemName: "arrow.clockwise.circle.fill")
                .imageScale(.large)
                .frame(width: 64, height: 64, alignment: .trailing)
                .accentColor(.white)
        }
    }
    
    var FavButton: some View {
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
            if favouritesManager.contains(place: place) {
                favouritesManager.updateScoreFor(place: place)
                busyScore = favouritesManager.getScoreFor(id: place.id)!
                updateScoreText(busyScore: busyScore)
            } else {
                busyScore = ML.model.run(on: [place]).first!
                updateScoreText(busyScore: busyScore)
            }
        }
    }
    
    private func updateScoreText(busyScore: BusyScore) {
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
