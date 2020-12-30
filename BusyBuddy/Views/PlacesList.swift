//
//  PlaceItem.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//

import SwiftUI
import CoreML
import os.log

struct PlacesList: View {    
    let places: [Place]
    
    var body: some View {
        List(places) { place in
            HStack {
                ZStack(alignment: .leading) {
                    Text(place.commonName).font(.headline)
                    NavigationLink(destination: PlaceDetail(place: place)) {
                        EmptyView()
                    }.buttonStyle(PlainButtonStyle()).opacity(0.0)
                }
                Spacer()
                DistanceText
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .center)
        }
        .listStyle(PlainListStyle())
    }
    
    private var DistanceText: some View {
        Text("1.4km").font(.footnote).padding(5).foregroundColor(Color.white).background(RoundedRectangle(cornerRadius: 100).fill(Color.gray))
    }
}

struct PlaceRow_Previews: PreviewProvider {
    static var previews: some View {
        PlacesList(places: [ExamplePlaces.oxfordCircus])
            .previewLayout(.sizeThatFits)
    }
}
