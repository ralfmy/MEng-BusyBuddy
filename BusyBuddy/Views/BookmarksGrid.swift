//
//  BookmarksGrid.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 29/11/2020.
//

import SwiftUI

import SwiftUI
import CoreML
import os.log

struct BookmarksGrid: View {
    @EnvironmentObject var bookmarksManager: BookmarksManager
    
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "BookmarksGrid")
        
    let columns: [GridItem] = [GridItem(.flexible(), spacing: 16, alignment: .center), GridItem(.flexible(), spacing: 16, alignment: .center)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 16, pinnedViews: [])
            {
                ForEach(bookmarksManager.getPlaces()) { place in
                    BookmarksGridItem(place: place)
                }
            }.padding(.leading).padding(.trailing)
            Spacer().frame(height: 30)
        }
    }
}

struct BookmarksGrid_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksGrid()
    }
}
