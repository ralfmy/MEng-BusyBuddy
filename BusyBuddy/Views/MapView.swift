//
//  MapView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/11/2020.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var jamCamsModel: JamCamsModel
    @EnvironmentObject var locationModel: LocationModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.509865, longitude: -0.118092),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    @State private var selectedJamCam: JamCam? = nil

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: self.jamCamsModel.getAllJamCams()) { jamCam in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: jamCam.lat, longitude: jamCam.lon)) {
                JamCamAnnotation()
                .onTapGesture {
                    self.selectedJamCam = jamCam
                }
            }
        }
        .sheet(item: self.$selectedJamCam) { jamCam in
            NavigationView {
                JamCamDetail(jamCam: self.jamCamsModel.getJamCamWithId(jamCam.id)!)
                    .navigationBarItems(trailing: Button(action: {
                        self.selectedJamCam = nil
                    }) {
                        Text("Done").foregroundColor(.white)
                    })
            }
        }
        .onAppear {
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: self.locationModel.userCoordinates.latitude, longitude: self.locationModel.userCoordinates.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
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
