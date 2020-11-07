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
    @State private var isShowingAll = false
    
    let viewOptions = ["Favourites", "All"]
    
    var body: some View {
        NavigationView {
            VStack {
                FavouritePlacesView(places: self.getFavouritePlaces())
                Spacer()
            }
            .navigationBarTitle(Text("Favourites"))
            .navigationBarItems(trailing: Button(action: {
                self.isShowingAll.toggle()
            }) {
                Image(systemName: "magnifyingglass.circle.fill").imageScale(.large)
                    .frame(width: 44, height: 44, alignment: .trailing)
            })
            
            .sheet(isPresented: $isShowingAll) {
                AllPlacesView(isPresented: self.$isShowingAll)
            }
        }
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
