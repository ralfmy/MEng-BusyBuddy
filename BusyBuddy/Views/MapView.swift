//
//  MapView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/11/2020.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var placesModel: PlacesModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.509865, longitude: -0.118092),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    @State private var selectedPlace: Place? = nil

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: self.placesModel.getAllPlaces()) { place in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)) {
                JamCamAnnotation()
                .onTapGesture {
                    self.selectedPlace = place
                }
            }
        }
        .sheet(item: self.$selectedPlace) { place in
            NavigationView {
                PlaceDetail(place: self.placesModel.getPlaceWithId(place.id)!)
                    .navigationBarItems(trailing: Button(action: {
                        self.selectedPlace = nil
                    }) {
                        Text("Done").foregroundColor(.white)
                    })
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct JamCamAnnotation: View {
    var body: some View {
        Image(systemName: "video.fill")
            .font(.caption2)
            .padding(12)
            .foregroundColor(.white)
            .background(Circle().strokeBorder(Color.white.opacity(0.8), lineWidth: 3).background(Circle().fill(Color.appBlue)))
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
