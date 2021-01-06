//
//  MapAnnotationView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/01/2021.
//

import SwiftUI

struct MapAnnotationView: View {
    
    @EnvironmentObject var bookmarksManager: BookmarksManager
    
    @State var place: Place
    @State private var tapped = false
    
    var body: some View {
        VStack {
            Text(self.place.commonName)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(8)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.appBlue).opacity(0.8))
                .onTapGesture {
                    self.tapped = true
                }
        }
        .sheet(isPresented: self.$tapped) {
            NavigationView {
                PlaceDetail(place: self.place)
                    .navigationBarItems(trailing: Button(action: {
                        self.tapped = false
                    }) {
                        Text("Done").foregroundColor(.white)
                    })
            }
        }
        
//        .background(NavigationLink(destination: PlaceDetail(place: place), isActive: self.$tapped) {
//            EmptyView()
//        }.buttonStyle(PlainButtonStyle()).opacity(0.0))
    }
}

struct MapAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        MapAnnotationView(place: ExamplePlaces.gowerSt)
            .previewLayout(.sizeThatFits)
    }
}
