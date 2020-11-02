//
//  PlaceItem.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//

import SwiftUI

struct PlaceItem: View {
    var place: CoreDataPlace
    
    var body: some View {
        Text("\(place.commonName)")
    }
}

struct PlaceItem_Previews: PreviewProvider {
    static var place = CoreDataPlace()
    
    init() {
        PlaceItem_Previews.place.commonName = "Oxford St"
    }

    static var previews: some View {
        PlaceItem(place: PlaceItem_Previews.place)
    }
}
