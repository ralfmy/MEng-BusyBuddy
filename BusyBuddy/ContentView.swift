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

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: CoreDataPlace.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CoreDataPlace.commonName, ascending: true)]
    ) var savedPlaces: FetchedResults<CoreDataPlace>
    
    let coreDataManager: CoreDataManager
    
    var body: some View {
        Text("TfL JamCams")
            .padding()
        
        VStack {
            Button("Fetch") {
                self.fetchAllJamCams()
            }
            Button("Load") {
                let savedPlaces = self.coreDataManager.loadSavedPlaces()
                if savedPlaces.count == 0 {
                    print("-- NO SAVED PLACES --")
                } else {
                    savedPlaces.forEach { place in
                        print("\(place.commonName): \(place.imageUrl)")
                    }
                    print("-- FINISHED LOADING --")
                }
            }
            Button("Delete") {
                self.coreDataManager.deleteAllPlaces()
            }
        }
        
    }
    
    func fetchAllJamCams() {
        TfLUnifiedAPI().fetchAllJamCams() { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let places):
                    let newPlaces = places.filter{ !savedPlaces.map{ $0.commonName }.contains($0.commonName) }
                    self.coreDataManager.savePlaces(places: newPlaces)
                case .failure(let err):
                    print("Failure to fetch: ", err)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistentContainer = CoreDataContainer().persistentContainer
        let managedObjectContext = persistentContainer.viewContext
        ContentView(coreDataManager: CoreDataManager(persistentContainer: persistentContainer, managedObjectContext: managedObjectContext))
    }
}
