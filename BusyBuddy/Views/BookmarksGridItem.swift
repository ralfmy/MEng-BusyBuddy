//
//  FavouriteItem.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 29/11/2020.
//

import SwiftUI

struct BookmarksGridItem: View {
    @EnvironmentObject var bookmarksManager: BookmarksManager
    
    @State private var tapped = false
    
    @State var place: Place
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Spacer().frame(height: 10)
                BusyIcon(busyScore: setBusyScore(), size: 50, coloured: false)
                Spacer().frame(height: 20)
                CommonName
                Spacer()
                BusyText(busyScore: setBusyScore(), font: .subheadline)
                LastUpdated
                Spacer().frame(height: 10)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 190, maxHeight: 190)
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20).fill(setCardColour()))
            .onTapGesture {
                self.tapped = true
            }
        }
        .background (NavigationLink(destination: PlaceDetail(place: place), isActive: $tapped) {
                EmptyView()
            }.buttonStyle(PlainButtonStyle()).opacity(0.0))
    }
    
    private var CommonName: some View {
        Text(setCommonName())
            .font(.headline)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .foregroundColor(setTextColour(opacity: 1))
    }
    
    private var LastUpdated: some View {
        Text(setLatUpdated())
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(setTextColour(opacity: 0.7))

    }
    
    private func setCommonName() -> String {
        if let place = bookmarksManager.getPlaceWith(id: place.id) {
            if let index = place.commonName.firstIndex(of: "/") {
                var commonName = place.commonName
                commonName.insert("\n", at: commonName.index(after: index))
                return commonName
            }
            return place.commonName
        } else {
            return ""
        }
    }
    
    func setBusyScore() -> BusyScore {
        if let busyScore = place.busyScore {
            return busyScore
        } else {
            return BusyScore()
        }
    }
    
    private func setLatUpdated() -> String {
        if let busyScore = place.busyScore {
            return busyScore.dateAsString()
        } else {
            return ""
        }
    }
    
    private func setTextColour(opacity: Double) -> Color {
        if let busyScore = place.busyScore {
            switch busyScore.score {
            case .none:
                return Color.appGreyDarkest.opacity(0.8)
            default:
                return Color.white.opacity(opacity)
            }
        } else {
            return Color.appGreyDarkest.opacity(0.8)
        }
    }

    private func setCardColour() -> Color {
        if let busyScore = place.busyScore {
            switch busyScore.score {
            case .none:
                return Color.busyGreyLighter
            case .low:
                return Color.busyGreenDarker
            case .medium:
                return Color.busyYellowDarker
            case.high:
                return Color.busyPinkDarker
            }
        } else {
            return Color.busyGreyLighter
        }
    }
}

struct FavouriteSgridItem_Previews: PreviewProvider {
    static let bookmarks = BookmarksManager()

    static var previews: some View {
        BookmarksGridItem(place: ExamplePlace.place)
            .previewLayout(.sizeThatFits).environmentObject(bookmarks)
    }
}
