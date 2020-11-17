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
import os.log

struct PlacesView: View {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "PlacesView")

    @EnvironmentObject var store: PlacesDataManager
    @EnvironmentObject var favouritesManager: FavouritesManager
    
    @State private var firstLoad = true
    @State private var isShowingAll = false
    @State private var busyScores = [BusyScore]()
    
    let viewOptions = ["Favourites", "All"]
    
    var body: some View {
        NavigationView {
            VStack {
                FavouritePlacesView(busyScores: $busyScores)
                Spacer()
            }
            .navigationBarTitle(Text("Favourites"))
            .navigationBarItems(leading: Button(action: {
                self.isShowingAll.toggle()
            }) {
                Image(systemName: "magnifyingglass.circle.fill").imageScale(.large)
                    .frame(width: 64, height: 64, alignment: .leading)
            }, trailing: Button(action: {
                updateScores()
            }) {
                Image(systemName: "arrow.clockwise.circle.fill").imageScale(.large).frame(width: 64, height: 64, alignment: .trailing)
            })
            .sheet(isPresented: $isShowingAll, onDismiss: {
                updateScores()
            }) {
                AllPlacesSheet(isPresented: self.$isShowingAll)
            }
            .onAppear {
                if self.firstLoad {
                    updateScores()
                    self.firstLoad = false
                }
            }
        }
    }
    
    func updateScores() {
        self.busyScores = ML.model.run(on: favouritesManager.getPlaces())
    }
}

struct ContentView_Previews: PreviewProvider {
    static let persistentContainer = PersistenceManager(.memory).container
    static let managedObjectContext = persistentContainer.viewContext
    static let store = PlacesDataManager(persistentContainer: persistentContainer, managedObjectContext: managedObjectContext)
    static let favourites = FavouritesManager()
    
    static var previews: some View {
        PlacesView().environmentObject(store).environmentObject(favourites)
    }
}
