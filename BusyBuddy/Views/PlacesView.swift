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

    @EnvironmentObject var placesManager: PlacesManager
    @EnvironmentObject var favouritesManager: FavouritesManager
    
    @State private var firstLoad = true
    @State private var isShowingAll = false
    
    var body: some View {
        NavigationView {
            VStack {
                FavouritesGrid()
                Spacer()
            }
            .navigationBarTitle(Text("Favourites"))
            .navigationBarItems(leading: SearchButton, trailing: UpdateButton)
            .sheet(isPresented: $isShowingAll, onDismiss: {
                updateScores()
            }) {
                AllPlacesSheet(isPresented: $isShowingAll)
            }
            .onAppear {
                if firstLoad {
                    updateScores()
                    firstLoad = false
                }
            }
        }.accentColor(.white)
    }

    private var SearchButton: some View {
        Button(action: {
            isShowingAll.toggle()
        }) {
            Image(systemName: "magnifyingglass.circle.fill")
                .imageScale(.large)
                .frame(width: 64, height: 64, alignment: .leading)
                .accentColor(.appBlue)
        }
    }
    
    private var UpdateButton: some View {
        Button(action: {
            updateScores()
        }) {
            Image(systemName: "arrow.clockwise.circle.fill")
                .imageScale(.large)
                .frame(width: 64, height: 64, alignment: .trailing)
                .accentColor(.appBlue)
        }
    }
    
    private func updateScores() {
        DispatchQueue.main.async {
            favouritesManager.updateScores()
        }
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
