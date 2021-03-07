//
//  BookmarksGrid.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 29/11/2020.
//

import SwiftUI
import CoreML

struct BookmarksGrid: View {
    @EnvironmentObject var bookmarksManager: BookmarksManager
        
    @State var activeId: String?
    
    let columns: [GridItem] = [GridItem(.flexible(), spacing: 16, alignment: .center), GridItem(.flexible(), spacing: 16, alignment: .center)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 16, pinnedViews: [])
            {
                ForEach(self.bookmarksManager.getPlaces()) { place in
                    BookmarksGridItem(id: place.id)
                }
            }.padding(.leading).padding(.trailing)
            .accessibility(identifier: "BookmarksGrid")
            Spacer().frame(height: 30)
        }
    }
}

struct BookmarksGrid_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksGrid()
    }
}
