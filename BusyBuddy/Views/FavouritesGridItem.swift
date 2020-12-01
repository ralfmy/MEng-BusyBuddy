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
                Spacer().frame(height: 20)
                BusyIcon(busyScore: favouritesManager.getScoreFor(id: id)!, size: 75)
                Spacer().frame(height: 12)
                Text(favouritesManager.getPlaceWith(id: id)!.commonName).font(.headline).lineLimit(2).multilineTextAlignment(.center).foregroundColor(Color.appGreyDarkest)
                Spacer()
                BusyText(busyScore: favouritesManager.getScoreFor(id: id)!)
                Text(favouritesManager.getScoreFor(id: id)!.dateAsString()).font(.caption).fontWeight(.semibold).foregroundColor(Color.appGreyDarker)
                Spacer().frame(height: 20)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 220, maxHeight: 220)
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.cardGrey))
            .onTapGesture {
                self.tapped = true
            }
        }
        .background (NavigationLink(destination: PlaceDetail(place: favouritesManager.getPlaceWith(id: id)!), isActive: $tapped) {
                EmptyView()
            }.buttonStyle(PlainButtonStyle()).opacity(0.0))
    }
}

struct FavouriteSgridItem_Previews: PreviewProvider {
    static let favourites = FavouritesManager()

    static var previews: some View {
        FavouritesGridItem(id: ExamplePlace.place.id)
            .previewLayout(.sizeThatFits).environmentObject(favourites)
    }
}
