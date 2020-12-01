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
                        HStack(alignment: .top) {
                            CommonName
                            FavButton
                        }
                        Spacer().frame(height: 27)
                    }
                }
                Spacer()
                BusyIcon(busyScore: favouritesManager.contains(place: place) ? setBusyScore() : busyScore, size: 100).padding()
                BusyText(busyScore: favouritesManager.contains(place: place) ? setBusyScore() : busyScore).padding()
                Spacer()
            }
        }
        .navigationBarItems(trailing: UpdateButton)
        .onAppear {
            if !favouritesManager.contains(place: place) {
                updateScore()
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
            Image(systemName: "arrow.clockwise")
                .font(Font.title2.weight(.bold))
                .foregroundColor(.white)
        }
    }
    
    private var FavButton: some View {
        Button(action: {
            if favouritesManager.contains(place: place) {
                busyScore = favouritesManager.getScoreFor(id: place.id)!
                favouritesManager.remove(place: place)
                buttonState = 0
            } else {
                favouritesManager.add(place: place, busyScore: busyScore)
                buttonState = 1
            }
        }) {
            buttonState == 0 ?
                Image(systemName: "star.circle.fill").font(.title).foregroundColor(.white) :
                Image(systemName: "star.circle.fill").font(.title).foregroundColor(.appBlue)
        }
        .padding(.leading, 10).padding(.trailing, 10)
    }
    
    func setBusyScore() -> BusyScore {
        if let busyScore = favouritesManager.getScoreFor(id: place.id) {
            return busyScore
        } else {
            return BusyScore(id: "")
        }
    }
    
    private func updateScore() {
        if favouritesManager.contains(place: place) {
            favouritesManager.updateScoreFor(place: place)
        } else {
            self.busyScore = BusyScore(id: place.id)
            DispatchQueue.global(qos: .userInteractive).async {
                let busyScore = ML.model.run(on: [place]).first!
                DispatchQueue.main.async {
                    self.busyScore = busyScore
                }
            }
        }
    }
}

struct PlaceDetail_Previews: PreviewProvider {
    static var previews: some View {
        PlaceDetail(place: ExamplePlace.place)
    }
}
