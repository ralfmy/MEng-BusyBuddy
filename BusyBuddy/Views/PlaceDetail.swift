//
//  PlaceDetail.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct PlaceDetail: View {
    @EnvironmentObject var bookmarksManager: BookmarksManager

    @State private var isViewingImage: Bool = false
    @State private var buttonState: Int = 0
    @State private var busyScore: BusyScore = BusyScore()
    @State private var scoreText = ""
    
    @StateObject var place: Place
    let feedback = UINotificationFeedbackGenerator()
    let impact = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                ZStack(alignment: .bottomLeading) {
                    PlaceMap(place: self.place).edgesIgnoringSafeArea(.all).frame(height: 300)
                    VStack {
                        HStack(alignment: .top) {
                            CommonName
                            FavButton
                        }
                        Spacer().frame(height: 27)
                    }
                }
                Spacer()
                BusyIcon(busyScore: setBusyScore(), size: 100, coloured: false).padding()
                BusyText(busyScore: setBusyScore(), font: .title2).padding(.bottom, 5 )
                LastUpdated
                Spacer()
                ViewImageButton
                Spacer().frame(height: 50)
            }
            .background(setBackgroundColour()).edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarItems(trailing: UpdateButton)
        .blur(radius: setBlurRadius())
        .overlay(ImageView(isShowing: $isViewingImage, busyScore: self.place.busyScore == nil ? BusyScore() : self.place.busyScore!))
        .onAppear {
            if bookmarksManager.contains(place: self.place) {
                buttonState = 1
            }
            updateScore()
        }
    }
    
    private var CommonName: some View {
        Text(self.place.commonName)
            .font(.title)
            .fontWeight(.bold)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding(.leading, 10).padding(.trailing, 10)
            .foregroundColor(Color.white)
    }
    
    private var LastUpdated: some View {
        Text(setLatUpdated())
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(Color.white.opacity(0.7))

    }

    private var UpdateButton: some View {
        Button(action: {
            impact.impactOccurred()
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
            impact.impactOccurred()
            if bookmarksManager.contains(place: self.place) {
                bookmarksManager.remove(place: self.place)
                buttonState = 0
            } else {
                bookmarksManager.add(place: self.place)
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
    
    private func setBusyScore() -> BusyScore {
        if let busyScore = self.place.busyScore {
            return busyScore
        } else {
            return BusyScore()
        }
    }
    
    private func updateScore() {
        if bookmarksManager.contains(place: self.place) {
            bookmarksManager.updateScoreFor(id: self.place.id)
        } else {
            self.place.updateBusyScore(busyScore: BusyScore())
            DispatchQueue.global(qos: .userInteractive).async {
                let image = self.place.downloadImage()
                let busyScore = ML.model.run(on: [image]).first!
                DispatchQueue.main.async { [self] in
                    self.place.updateBusyScore(busyScore: busyScore)
                    self.feedback.notificationOccurred(.success)
                }
            }
        }
    }
    
    private func setLatUpdated() -> String {
        if let busyScore = self.place.busyScore {
            return "Last Updated: " + busyScore.dateAsString()
        } else {
            return "Last Updated: " + self.busyScore.dateAsString()
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
        if let busyScore = self.place.busyScore {
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
        return Color.busyGreyLighter
    }
}

struct PlaceDetail_Previews: PreviewProvider {
    static var previews: some View {
        PlaceDetail(place: ExamplePlaces.oxfordCircus)
    }
}
