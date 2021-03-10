//
//  PlaceDetail.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct PlaceDetail: View {
    @EnvironmentObject private var placesModel: PlacesModel
//    @EnvironmentObject private var bookmarksManager: BookmarksManager

    @State private var isViewingImage: Bool = false
    @State private var buttonState: Int = 0
    @State private var busyScore: BusyScore = BusyScore()
    @State private var scoreText = ""
    
    let place: Place
    let feedback = UINotificationFeedbackGenerator()
    let impact = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ZStack { [weak placesModel] in
            VStack(alignment: .center) {
                ZStack(alignment: .bottomLeading) {
                    PlaceMap(place: self.place).edgesIgnoringSafeArea(.all).frame(height: 300)
                    VStack {
                        HStack(alignment: .top) {
                            VStack {
                                CommonName
                                CameraView
                            }
                            FavButton
                        }
                        Spacer().frame(height: 27)
                    }
                }
                Spacer()
                BusyIcon(busyScore: self.place.busyScore ?? BusyScore(), size: 100, coloured: false).padding()
                BusyText(busyScore: self.place.busyScore ?? BusyScore(), font: .title2).padding(.bottom, 5)
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
            if self.placesModel.isBookmark(id: self.place.id) {
                buttonState = 1
            } else {
                self.placesModel.updateScoreFor(id: self.place.id)
            }
        }
    }
    
    private var CommonName: some View {
        Text(self.place.commonNameAsText())
            .font(.title)
            .fontWeight(.bold)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding(.leading, 10).padding(.trailing, 10)
            .foregroundColor(Color.white)
    }
    
    private var CameraView: some View {
        Text(self.place.getCameraView())
            .font(.subheadline)
            .fontWeight(.semibold)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding(.leading, 10).padding(.trailing, 10)
            .foregroundColor(Color.white)
    }
    
    private var LastUpdated: some View {
        Text("Last Updated " + self.getBusyScore().dateAsString())
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(Color.white.opacity(0.7))
    }

    private var UpdateButton: some View {
        Button(action: {
            self.impact.impactOccurred()
            self.placesModel.updateScoreFor(id: self.place.id)
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
            if self.placesModel.isBookmark(id: self.place.id) {
                self.placesModel.removeBookmark(id: self.place.id)
                self.placesModel.updateScoreFor(id: self.place.id)
                buttonState = 0
            } else {
                self.placesModel.addBookmark(id: self.place.id)
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
    
    private func getBusyScore() -> BusyScore {
        let busyScore = self.place.busyScore ?? BusyScore()
        return busyScore
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
        PlaceDetail(place: ExamplePlaces.oxfordCircus)
    }
}
