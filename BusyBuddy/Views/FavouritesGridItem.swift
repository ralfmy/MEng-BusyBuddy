//
//  FavouriteItem.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 29/11/2020.
//

import SwiftUI

struct FavouritesGridItem: View {
    @EnvironmentObject var favouritesManager: FavouritesManager
    
    @State private var tapped = false
    
    let id: String
    
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Spacer().frame(height: 15)
                BusyIcon(busyScore: setBusyScore(), size: 75)
                Spacer().frame(height: 20)
                Text(setCommonName()).font(.headline).lineLimit(2).multilineTextAlignment(.center).foregroundColor(Color.appGreyDarkest)
                Spacer()
                BusyText(busyScore: setBusyScore())
                Text(setLatUpdated()).font(.caption).fontWeight(.semibold).foregroundColor(Color.appGreyDarker)
                Spacer().frame(height: 15)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 230, maxHeight: 230)
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.cardGrey))
            .onTapGesture {
                self.tapped = true
            }
        }
        .background (NavigationLink(destination: PlaceDetail(place: setPlaceDetail()), isActive: $tapped) {
                EmptyView()
            }.buttonStyle(PlainButtonStyle()).opacity(0.0))
    }
    
    private func setCommonName() -> String {
        if let place = favouritesManager.getPlaceWith(id: id) {
            return place.commonName
        } else {
            return ""
        }
    }
    
    func setBusyScore() -> BusyScore {
        if let busyScore = favouritesManager.getScoreFor(id: id) {
            return busyScore
        } else {
            return BusyScore(id: "")
        }
    }
    
    private func setLatUpdated() -> String {
        if let busyScore = favouritesManager.getScoreFor(id: id) {
            return busyScore.dateAsString()
        } else {
            return ""
        }
    }
    
    private func setPlaceDetail() -> Place {
        if let place = favouritesManager.getPlaceWith(id: id) {
            return place
        } else {
            return ExamplePlace.place
        }
    }
}

struct FavouriteSgridItem_Previews: PreviewProvider {
    static let favourites = FavouritesManager()

    static var previews: some View {
        FavouritesGridItem(id: ExamplePlace.place.id)
            .previewLayout(.sizeThatFits).environmentObject(favourites)
    }
}
