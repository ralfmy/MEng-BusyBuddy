//
//  PlaceDetail.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct PlaceDetail: View {
    @EnvironmentObject var bookmarksManager: BookmarksManager

    @State private var buttonState: Int = 0
    @State private var busyScore: BusyScore = BusyScore(id: "")
    @State private var scoreText = ""
    
    let place: Place
    let feedback = UINotificationFeedbackGenerator()
    let impact = UIImpactFeedbackGenerator(style: .light)
    
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
                BusyIcon(busyScore: bookmarksManager.contains(place: place) ? setBusyScore() : busyScore, size: 100).padding()
                BusyText(busyScore: bookmarksManager.contains(place: place) ? setBusyScore() : busyScore).padding()
                Spacer()
            }
        }
        .navigationBarItems(trailing: UpdateButton)
        .onAppear {
            if bookmarksManager.contains(place: place) {
                buttonState = 1
            } else {
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
            impact.impactOccurred()
            updateScore()
        }) {
            Image(systemName: "arrow.clockwise")
                .font(Font.title2.weight(.bold))
                .foregroundColor(.white)
        }
    }
    
    private var FavButton: some View {
        Button(action: {
            impact.impactOccurred()
            if bookmarksManager.contains(place: place) {
                busyScore = bookmarksManager.getScoreFor(id: place.id)!
                bookmarksManager.remove(place: place)
                buttonState = 0
            } else {
                bookmarksManager.add(place: place, busyScore: busyScore)
                buttonState = 1
            }
        }) {
            buttonState == 0 ?
                Image(systemName: "bookmark.fill").font(.title).foregroundColor(Color.white.opacity(0.5)) :
                Image(systemName: "bookmark.fill").font(.title).foregroundColor(.red)
        }
        .padding(.leading, 10).padding(.trailing, 10)
    }
    
    func setBusyScore() -> BusyScore {
        if let busyScore = bookmarksManager.getScoreFor(id: place.id) {
            return busyScore
        } else {
            return BusyScore(id: "")
        }
    }
    
    private func updateScore() {
        if bookmarksManager.contains(place: place) {
            bookmarksManager.updateScoreFor(place: place)
        } else {
            self.busyScore = BusyScore(id: place.id)
            DispatchQueue.global(qos: .userInteractive).async {
                let busyScore = ML.model.run(on: [place]).first!
                DispatchQueue.main.async {
                    self.busyScore = busyScore
                    self.feedback.notificationOccurred(.success)
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
