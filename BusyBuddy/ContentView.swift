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
    
    var body: some View {
        Text("TfL JamCams")
            .padding()
        
        VStack {
            Button("Fetch") {
                self.fetchAllJamCams()
            }
            Button("Load") {
                self.loadPlaces()
            }
            Button("Delete") {
                self.deleteAll()
            }
        }
        
    }
    
    func fetchAllJamCams() {
        TfLUnifiedAPI().fetchAllJamCams() { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let places):
                    let newPlaces = places.filter{ !savedPlaces.map{ $0.commonName }.contains($0.commonName) }
                    self.savePlaces(places: newPlaces)
                case .failure(let err):
                    print("Failure to fetch: ", err)
                }
            }
        }
    }
    
    func savePlaces(places: [Place]) {
        managedObjectContext.performAndWait {
            places.forEach { place in
                let cdPlace = CoreDataPlace(context: self.managedObjectContext)
                cdPlace.commonName = place.commonName
                cdPlace.placeType = place.placeType
                cdPlace.imageUrl = place.additionalProperties.filter({$0.key == "imageUrl"})[0].value
                cdPlace.lat = place.lat
                cdPlace.lon = place.lon
            }
        }
        
        if self.managedObjectContext.hasChanges {
            do {
                try self.managedObjectContext.save()
                print("Changes saved")
            } catch {
                print("Error occurred while saving: \(error)")
            }
        } else {
            print("no changes")
        }
    }
    
    func deleteAll() {
        savedPlaces.forEach{ place in
            self.managedObjectContext.delete(place)
        }
        
        do {
            try self.managedObjectContext.save()
            print("Successfully deleted")
        } catch {
            print("Error occurred while deleting: \(error)")
        }
    }
    
    func loadPlaces() {
        savedPlaces.forEach { place in
            print("\(place.commonName): \(place.imageUrl)")
        }
        print("Finished loading")
        if savedPlaces.count == 0 {
            print("No places")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
