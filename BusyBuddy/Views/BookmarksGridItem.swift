//
//  FavouriteItem.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 29/11/2020.
//

import SwiftUI

struct BookmarksGridItem: View {    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var placesModel: PlacesModel
    
    var place: Place
    
    var body: some View {
        VStack { [weak appState, weak placesModel] in
            VStack(alignment: .leading) {
                Spacer().frame(height: 10)
                BusyIcon(busyScore: self.place.busyScore ?? BusyScore(), size: 50, coloured: false)
                Spacer().frame(height: 20)
                CommonName
                Spacer()
                BusyText(busyScore: self.place.busyScore ?? BusyScore(), font: .subheadline)
                LastUpdated
                Spacer().frame(height: 10)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 190, maxHeight: 190)
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20).fill(setCardColour()))
            .onTapGesture {
                self.appState.placeSelectionId = self.place.id
            }
        }
        .background(NavigationLink(destination: PlaceDetail(place: self.placesModel.getPlaceWithId(self.place.id)!), tag: self.place.id, selection: self.$appState.placeSelectionId) {
                EmptyView()
            }.buttonStyle(PlainButtonStyle()).opacity(0.0))
    }
    
    private var CommonName: some View {
        Text(self.place.commonNameAsText())
            .font(.headline)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .foregroundColor(setTextColour(opacity: 1))
    }
    
    private var LastUpdated: some View {
        Text(self.place.busyScore?.dateAsString() ?? "")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(setTextColour(opacity: 0.7))
    }
    
    private func setTextColour(opacity: Double) -> Color {
        let busyScore = self.place.busyScore ?? BusyScore()
        switch busyScore.score {
        case .none:
            return Color.appGreyDarkest.opacity(0.8)
        default:
            return Color.white.opacity(opacity)
        }
    }

    private func setCardColour() -> Color {
        let busyScore = self.place.busyScore ?? BusyScore()
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

struct BookmarksGridItem_Preview: PreviewProvider {
    static var previews: some View {
        BookmarksGridItem(place: ExamplePlaces.oxfordCircus).previewLayout(.sizeThatFits)
    }
}
