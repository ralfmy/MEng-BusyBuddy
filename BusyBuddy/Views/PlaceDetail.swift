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
                ZStack(alignment: .bottomLeading) {
                    PlaceMap(place: place).edgesIgnoringSafeArea(.all).frame(height: 300)
                    VStack {
                        HStack(alignment: .bottom) {
                            CommonName
                            FavButton
                        }
                        Spacer().frame(height: 27)
                    }
                }
                Spacer()
                BusyIcon(busyScore: busyScore, size: 100)
                BusyText(busyScore: busyScore)
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
    
    private var CommonName: some View {
        Text(place.commonName)
            .font(.title)
            .fontWeight(.bold)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding(.leading, 10).padding(.trailing, 10)
            .foregroundColor(Color.white)
    }

    private var UpdateButton: some View {
        Button(action: {
            updateScore()
        }) {
            Image(systemName: "arrow.clockwise.circle.fill")
                .font(.title)
                .foregroundColor(.white)
        }
    }
    
    private var FavButton: some View {

        Button(action: {
            if favouritesManager.contains(place: place) {
                favouritesManager.remove(place: place)
                buttonState = 0
            } else {
                favouritesManager.add(place: place)
                buttonState = 1
            }
        }) {
            buttonState == 0 ?
                Image(systemName: "star.circle.fill").font(.title).foregroundColor(.white) :
                Image(systemName: "star.circle.fill").font(.title).foregroundColor(.appBlue)
        }
        .padding(.leading, 10).padding(.trailing, 10)
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
