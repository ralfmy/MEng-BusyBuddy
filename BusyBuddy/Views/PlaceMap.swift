//
//  PlaceMap.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 18/11/2020.
//

import SwiftUI
import MapKit

struct PlaceMap: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    let place: Place
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Map(coordinateRegion: $region, annotationItems: [place]) { place in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon))
            }
            .frame(height: 400)
            .brightness(-0.2)
            .onAppear {
                region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            }
            CommonName
        }
    }
    
    private var CommonName: some View {
        Text(place.commonName)
            .font(.title)
            .fontWeight(.bold)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8).padding(.bottom, 27).padding(.leading, 8).padding(.trailing, 8)
            .foregroundColor(Color.white)
    }
}

struct PlaceMap_Previews: PreviewProvider {
    static var previews: some View {
        PlaceMap(place: ExamplePlace.place)
            .previewLayout(.sizeThatFits)
    }
}
