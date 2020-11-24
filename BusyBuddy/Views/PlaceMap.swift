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
        Map(coordinateRegion: $region, annotationItems: [place]) { place in
            MapMarker(coordinate: CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon))
        }
        .frame(height: 300)
        .onAppear {
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.place.lat, longitude: self.place.lon), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
    }
}

struct PlaceMap_Previews: PreviewProvider {
    static var previews: some View {
        PlaceMap(place: PlaceExample.place)
    }
}
