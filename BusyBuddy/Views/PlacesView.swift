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
    @EnvironmentObject var store: PlacesDataManager
    @EnvironmentObject var favourites: Favourites
    @State private var selectedView = 0
    
    let viewOptions = ["Favourites", "All"]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("View Options", selection: $selectedView) {
                    ForEach(0..<viewOptions.count) { index in
                        Text(self.viewOptions[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if self.selectedView == 0 {
                    FavouritePlacesView(places: self.getFavouritePlaces())
                } else {
                    AllPlacesView()
                }
                Spacer()
            }
            .navigationBarTitle(Text("Places"))
            .navigationBarItems(trailing: Button("Delete All") {
                store.deleteAllSavedPlaces()
            })
        }.environmentObject(self.store).environmentObject(self.favourites)
    }
    
    func getFavouritePlaces() -> [Place] {
        let ids = favourites.ids()
        var places = [Place]()
        ids.sorted().forEach { id in
            places.append(store.findPlace(with: id)!)
        }
        return places
    }
}

struct ContentView_Previews: PreviewProvider {
    static let persistentContainer = PersistenceManager(.memory).container
    static let managedObjectContext = persistentContainer.viewContext
    static let store = PlacesDataManager(persistentContainer: persistentContainer, managedObjectContext: managedObjectContext)
    static let favourites = Favourites()
    static var previews: some View {
        PlacesView().environmentObject(store).environmentObject(favourites)
    }
}
