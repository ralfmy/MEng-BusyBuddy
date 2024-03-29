//
//  JamCamDetail.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct JamCamDetail: View {
    @EnvironmentObject private var jamCamsManager: JamCamsManager

    @State private var isViewingImage: Bool = false
    @State private var buttonState: Int = 0
    @State private var busyScore: BusyScore = BusyScore()
    @State private var scoreText = ""
    
    let jamCam: JamCam
    let feedback = UINotificationFeedbackGenerator()
    let impact = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ZStack { [weak jamCamsManager] in
            VStack(alignment: .center) {
                ZStack(alignment: .bottomLeading) {
                    JamCamMap(jamCam: self.jamCam).edgesIgnoringSafeArea(.all).frame(height: 300)
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
                BusyIcon(busyScore: self.jamCam.busyScore ?? BusyScore(), size: 100, coloured: false).padding()
                BusyText(busyScore: self.jamCam.busyScore ?? BusyScore(), font: .title2).padding(.bottom, 5)
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
            if self.jamCamsManager.isBookmark(id: self.jamCam.id) {
                buttonState = 1
            } else {
                self.jamCamsManager.updateScoreFor(id: self.jamCam.id)
            }
        }
    }
    
    private var CommonName: some View {
        Text(self.jamCam.formattedCommonName())
            .font(.title)
            .fontWeight(.bold)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding(.leading, 10).padding(.trailing, 10)
            .foregroundColor(Color.white)
    }
    
    private var CameraView: some View {
        Text(self.jamCam.getCameraView())
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
            self.jamCamsManager.updateScoreFor(id: self.jamCam.id)
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
            if self.jamCamsManager.isBookmark(id: self.jamCam.id) {
                self.jamCamsManager.removeBookmark(id: self.jamCam.id)
                self.jamCamsManager.updateScoreFor(id: self.jamCam.id)
                buttonState = 0
            } else {
                self.jamCamsManager.addBookmark(id: self.jamCam.id)
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
            Text("VIEW IMAGE")
                .font(.caption)
                .fontWeight(.bold)
                .padding()
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(100)
        }
    }
    
    private func getBusyScore() -> BusyScore {
        let busyScore = self.jamCam.busyScore ?? BusyScore()
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
        case .notbusy:
            return Color.busyGreenDarker
        case .busy:
            return Color.busyPinkDarker
        case .unsure:
            return Color.busyYellowDarker
        }
    }
}

struct JamCamDetail_Previews: PreviewProvider {
    static var previews: some View {
        JamCamDetail(jamCam: ExampleJamCams.oxfordCircus)
    }
}
