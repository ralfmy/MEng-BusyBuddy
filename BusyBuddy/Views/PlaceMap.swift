//
//  JamCamMap.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 18/11/2020.
//
//  With help from:
//  https://developer.apple.com/tutorials/swiftui/creating-and-combining-views

import SwiftUI
import MapKit

struct JamCamMap: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    @State private var jamCams = [JamCam]()
    
    let jamCam: JamCam
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: self.jamCams) { jamCam in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: jamCam.lat, longitude: jamCam.lon)) {
                JamCamAnnotation()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .brightness(-0.2)
        .onAppear {
            self.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: self.jamCam.lat, longitude: self.jamCam.lon),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.jamCams.append(self.jamCam)
        }
    }
}

struct JamCamMap_Previews: PreviewProvider {
    static var previews: some View {
        JamCamMap(jamCam: ExampleJamCams.oxfordCircus)
            
    }
}
