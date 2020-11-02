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

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: CoreDataPlace.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CoreDataPlace.commonName, ascending: true)]
    ) var savedPlaces: FetchedResults<CoreDataPlace>
    
    let coreDataManager: CoreDataManager
    
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "ContentView")
    
    var body: some View {
        Text("TfL JamCams")
            .padding()
        
        VStack {
            Button("Fetch") {
                self.fetchAllJamCams()
            }
            Button("Load") {
                let savedPlaces = self.coreDataManager.loadAllSavedPlaces()
                if savedPlaces.count == 0 {
                    self.logger.info("INFO: No saved places.")
                } else {
                    savedPlaces.forEach { place in
                        self.logger.info("INFO: \(place.id): \(place.commonName) - \(place.imageUrl)")
                    }
                    self.logger.info("INFO: Finished loading \(savedPlaces.count) places.")
                }
            }
            Button("Delete") {
                self.coreDataManager.deleteAllSavedPlaces()
            }
        }
        
    }
    
    func fetchAllJamCams() {
        TfLUnifiedAPI().fetchAllJamCams() { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let places):
                    self.coreDataManager.savePlaces(places: places)
                case .failure(let err):
                    self.logger.error("ERROR: Failure to fetch: \(err as NSObject)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistentContainer = CoreDataPersistence().container
        let managedObjectContext = persistentContainer.viewContext
        ContentView(coreDataManager: CoreDataManager(persistentContainer: persistentContainer, managedObjectContext: managedObjectContext))
    }
}
