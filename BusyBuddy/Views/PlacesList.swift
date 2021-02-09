//
//  PlaceItem.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//
//  With help from:
//  https://www.appcoda.com/swiftui-search-bar/

import SwiftUI
import CoreML
import os.log

struct PlacesList: View {
    
    @State private var isEditing = false
    @State private var query : String = ""
    
    let places: [Place]
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: $query)
                    .padding(12).padding(.leading, 28)
                    .background(Color.busyGreyLighter)
                    .cornerRadius(12)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.appGreyDarker)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 12)
                            if self.isEditing && !self.query.isEmpty {
                                Button(action: {
                                    self.isEditing = false
                                    self.query = ""
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.appGreyDarker)
                                        .padding(.trailing, 12)
                                }
                            }
                        }
                    )
                    .onTapGesture {
                        self.isEditing = true
                    }
            }
            .padding(.leading).padding(.trailing)
            List(places.filter({ self.query.isEmpty ? true : $0.commonName.contains(query) })) { place in
                HStack {
                    ZStack(alignment: .leading) {
                        Text(place.commonName).font(.headline)
                        NavigationLink(destination: PlaceDetail(place: place)) {
                            EmptyView()
                        }.buttonStyle(PlainButtonStyle()).opacity(0.0)
                    }
                    Spacer()
    //                DistanceText
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .center)
            }
            .listStyle(PlainListStyle())
        }
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
