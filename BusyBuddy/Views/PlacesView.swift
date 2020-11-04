//
//  ContentView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 31/10/2020.
//
//  With help from
//  https://www.hackingwithswift.com/quick-start/swiftui/introduction-to-using-core-data-with-swiftui 

import SwiftUI
import CoreData

struct PlacesView: View {
    @EnvironmentObject var placesDataManager: PlacesDataManager
        
    var body: some View {
        NavigationView {
            List(placesDataManager.places) { place in
                PlaceItem(place: place)
            }
            .navigationBarTitle(Text("Places"))
//            .navigationBarItems(trailing: Button("Delete All") {
//                placesDataManager.deleteAllSavedPlaces()
//            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let persistentContainer = CoreDataPersistence(.memory).container
    static let managedObjectContext = persistentContainer.viewContext
    static let placesDataManager = PlacesDataManager(persistentContainer: persistentContainer, managedObjectContext: managedObjectContext)
    static var previews: some View {
        PlacesView().environmentObject(placesDataManager)
    }
}
