//
//  PlaceItem.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//

import SwiftUI

struct PlacesList: View {
    @EnvironmentObject private var placesModel: PlacesModel
    
    @State private var isEditing = false
    @State private var query : String = ""
        
    var body: some View {
        VStack { [weak placesModel] in
            SearchBar(query: $query)
            
            List(self.placesModel.getAllPlaces().filter({ self.query.isEmpty ? true : $0.commonName.contains(query) })) { place in
                HStack {
                    ZStack(alignment: .leading) {
                        Text(place.commonName).font(.headline)
                        NavigationLink(destination: PlaceDetail(place: self.placesModel.getPlaceAtIndex(self.placesModel.getIndexOfId(place.id)!))) {
                            EmptyView()
                        }.buttonStyle(PlainButtonStyle()).opacity(0.0)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .center)
                }
            }.listStyle(PlainListStyle())
        }
    }
    
    private var DistanceText: some View {
        Text("1.4km").font(.footnote).padding(5).foregroundColor(Color.white).background(RoundedRectangle(cornerRadius: 100).fill(Color.gray))
    }
}

struct PlaceRow_Previews: PreviewProvider {
    static var previews: some View {
        PlacesList()
            .previewLayout(.sizeThatFits)
    }
}
