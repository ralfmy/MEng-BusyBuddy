//
//  BookmarksGrid.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 29/11/2020.
//

import SwiftUI
import CoreML

struct BookmarksGrid: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var jamCamsModel: JamCamsModel
        
    let columns: [GridItem] = [GridItem(.flexible(), spacing: 16, alignment: .center), GridItem(.flexible(), spacing: 16, alignment: .center)]
    
    @ViewBuilder
    var body: some View {
        if !self.jamCamsModel.getBookmarkIds().isEmpty {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 16, pinnedViews: [])
                {
                    ForEach(self.jamCamsModel.getBookmarkIds(), id: \.self) { id in
                        BookmarksGridItem(jamCam: self.jamCamsModel.getJamCamWithId(id)!)
                    }
                }.padding(.leading).padding(.trailing)
                .accessibility(identifier: "BookmarksGrid")
                Spacer().frame(height: 30)
            }
        } else {
            VStack {
                Image(systemName: "safari.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.busyGreyLighter)
                
                Spacer().frame(height: 40)
                
                Text("EXPLORE PLACES")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.appBlue)
                    .onTapGesture {
                        self.appState.tabSelection = .map
                    }
            }
        }
    }
}

struct BookmarksGrid_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksGrid()
    }
}
