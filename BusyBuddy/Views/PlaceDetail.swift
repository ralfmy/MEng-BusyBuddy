//
//  PlaceDetail.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct PlaceDetail: View {
    @EnvironmentObject private var placesManager: PlacesManager
    @EnvironmentObject private var bookmarksManager: BookmarksManager

    @State private var isViewingImage: Bool = false
    @State private var buttonState: Int = 0
    @State private var busyScore: BusyScore = BusyScore()
    @State private var scoreText = ""
    
//    @StateObject var place: Place
    let id: String
    let feedback = UINotificationFeedbackGenerator()
    let impact = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ZStack { [weak placesManager, weak bookmarksManager] in
            VStack(alignment: .center) {
                ZStack(alignment: .bottomLeading) {
                    PlaceMap(id: self.id).edgesIgnoringSafeArea(.all).frame(height: 300)
                    VStack {
                        HStack(alignment: .top) {
                            CommonName
                            FavButton
                        }
                        Spacer().frame(height: 27)
                    }
                }
                Spacer()
                BusyIcon(id: self.id, size: 100, coloured: false).padding()
                BusyText(id: self.id, font: .title2).padding(.bottom, 5 )
                LastUpdated
                Spacer()
                ViewImageButton
                Spacer().frame(height: 50)
            }
            .background(setBackgroundColour()).edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarItems(trailing: UpdateButton)
        .blur(radius: setBlurRadius())
        .overlay(ImageView(isShowing: $isViewingImage, busyScore: getBusyScore()))
        .onAppear {
            if isBookmark() {
                buttonState = 1
            } else {
                updateScore()
            }
        }
    }
    
    private var CommonName: some View {
        Text(self.placesManager.getPlaceWith(id: self.id)?.commonNameText() ?? "")
            .font(.title)
            .fontWeight(.bold)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding(.leading, 10).padding(.trailing, 10)
            .foregroundColor(Color.white)
    }
    
    private var LastUpdated: some View {
        Text("Last Updated " + getBusyScore().dateAsString())
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(Color.white.opacity(0.7))

    }

    private var UpdateButton: some View {
        Button(action: {
            self.impact.impactOccurred()
            updateScore()
        }) {
            Image(systemName: "arrow.clockwise")
                .font(Font.title3.weight(.bold))
                .frame(width: 64, height: 64, alignment: .trailing)
                .foregroundColor(.white)
        }
    }
    
    private var FavButton: some View {
        Button(action: {
            self.impact.impactOccurred()
            if isBookmark() {
                self.bookmarksManager.remove(id: self.id)
                updateScore()
                buttonState = 0
            } else {
                let place = self.placesManager.getPlaceWith(id: self.id)!
                self.bookmarksManager.add(place: place)
                buttonState = 1
            }
        }) {
            buttonState == 0 ?
                Image(systemName: "bookmark.fill").font(.title).foregroundColor(Color.white.opacity(0.8)) :
                Image(systemName: "bookmark.fill").font(.title).foregroundColor(.red)
        }
        .padding(.leading, 10).padding(.trailing, 10)
    }
    
    private var ViewImageButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isViewingImage.toggle()
            }
        }) {
            Text("View Image")
                .font(.subheadline)
                .fontWeight(.bold)
                .padding()
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(100)
        }
    }
    
    private func isBookmark() -> Bool {
        return self.bookmarksManager.contains(id: self.id)
    }
    
    private func getBusyScore() -> BusyScore {
        var busyScore: BusyScore
        if isBookmark() {
            if let bs = self.bookmarksManager.getPlaceWith(id: self.id)!.busyScore {
                busyScore = bs
            } else {
                busyScore = BusyScore()
            }
        } else {
            if let bs = self.placesManager.getPlaceWith(id: self.id)!.busyScore {
                busyScore = bs
            } else {
                busyScore = BusyScore()
            }
        }
        
        return busyScore
    }
    
    private func updateScore() {
        if isBookmark() {
            self.bookmarksManager.updateScoreFor(id: self.id)
        } else {
            self.placesManager.updateScoreFor(id: self.id)
        }
    }
    
    private func setBlurRadius() -> CGFloat {
        if isViewingImage {
            return 3
        } else {
            return 0
        }
    }
    
    private func setBackgroundColour() -> Color {
        let busyScore = getBusyScore()
        switch busyScore.score {
        case .none:
            return Color.busyGreyLighter
        case .low:
            return Color.busyGreenDarker
        case .medium:
            return Color.busyYellowDarker
        case .high:
            return Color.busyPinkDarker
        case .unsure:
            return Color.busyYellowDarker
        }
    }
}

struct PlaceDetail_Previews: PreviewProvider {
    static var previews: some View {
        PlaceDetail(id: ExamplePlaces.oxfordCircus.id)
    }
}
