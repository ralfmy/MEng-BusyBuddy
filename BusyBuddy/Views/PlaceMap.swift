//
//  PlaceMap.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 18/11/2020.
//
//  With help from:
//  https://developer.apple.com/tutorials/swiftui/creating-and-combining-views

import SwiftUI
import MapKit

struct PlaceMap: View {
    @EnvironmentObject private var placesManager: PlacesManager
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    @State private var places = [Place]()
    
//    let place: Place
    let id: String
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: self.places) { place in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)) {
                JamCamAnnotation()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .brightness(-0.2)
        .onAppear {
            let place = self.placesManager.getPlaceWith(id: self.id)!
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.places.append(place)
        }
    }
}

struct PlaceMap_Previews: PreviewProvider {
    static var previews: some View {
        PlaceMap(id: ExamplePlaces.oxfordCircus.id)
            
    }
}
