//
//  LocationModel.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 16/03/2021.
//
//  With help from:
//  https://adrianhall.github.io/swift/2019/11/05/swiftui-location/
//  https://stackoverflow.com/questions/61993353/request-user-location-permission-in-swiftui
//  https://www.raywenderlich.com/5247-core-location-tutorial-for-ios-tracking-visited-locations

import Foundation
import CoreLocation

class LocationModel: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var authorisationStatus: CLAuthorizationStatus = .notDetermined
    @Published var userCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.509865, longitude: -0.118092)
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
}

extension LocationModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorisationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.userCoordinates = coordinates
    }
}
