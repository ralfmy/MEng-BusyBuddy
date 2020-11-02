//
//  CoreDataPlace+CoreDataProperties.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 01/11/2020.
//
//

import Foundation
import CoreData


extension CoreDataPlace {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<CoreDataPlace> {
        return NSFetchRequest<CoreDataPlace>(entityName: "CoreDataPlace")
    }
    
    @NSManaged public var id: String
    @NSManaged public var commonName: String
    @NSManaged public var placeType: String
    @NSManaged public var imageUrl: String
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double

}

extension CoreDataPlace : Identifiable {

}
