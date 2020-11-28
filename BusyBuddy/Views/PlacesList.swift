//
//  PlaceItem.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//

import SwiftUI
import CoreML
import os.log

struct PlacesList: View {
    @State private var action: Int? = 0
    
    let place: Place
    
    var body: some View {
        
        NavigationLink(destination: PlaceDetail(place: place), tag: 1, selection: $action) {
            Text(place.commonName)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .center)
    }
}

struct PlaceRow_Previews: PreviewProvider {
    static var previews: some View {
        PlacesList(place: PlaceExample.place)
    }
}
