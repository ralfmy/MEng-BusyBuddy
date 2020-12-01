//
//  FavouritesGrid.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 29/11/2020.
//

import SwiftUI

import SwiftUI
import CoreML
import os.log

struct FavouritesGrid: View {
    @EnvironmentObject var favouritesManager: FavouritesManager
    
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "FavouritesGrid")
    
    let columns: [GridItem] = [GridItem(.flexible(), spacing: 8, alignment: .center), GridItem(.flexible(), spacing: 8, alignment: .center)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 8, pinnedViews: [])
            {
                ForEach(favouritesManager.places) { place in
                    FavouritesGridItem(id: place.id)
                }
            }.padding(.leading).padding(.trailing)
            Spacer().frame(height: 30)
        }
    }
}

struct FavouritesGrid_Previews: PreviewProvider {
    static var previews: some View {
        FavouritesGrid()
    }
}
