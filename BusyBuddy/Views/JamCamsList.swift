//
//  JamCamItem.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//

import SwiftUI

struct JamCamsList: View {
    @EnvironmentObject private var jamCamsManager: JamCamsManager
    
    @State private var isEditing = false
    @State private var query : String = ""
        
    var body: some View {
        VStack { [weak jamCamsManager] in
            SearchBar(query: $query)
            
            List(self.jamCamsManager.getAllJamCams().filter({ self.query.isEmpty ? true : $0.commonName.contains(query) })) { jamCam in
                HStack {
                    ZStack(alignment: .leading) {
                        Text(jamCam.commonName).font(.headline)
                        NavigationLink(destination: JamCamDetail(jamCam: jamCam)) {
                            EmptyView()
                        }.buttonStyle(PlainButtonStyle()).opacity(0.0)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .center)
                }
            }.listStyle(PlainListStyle())
        }
    }
    
    private var DistanceText: some View {
        Text("1.4km").font(.footnote).padding(5).foregroundColor(Color.white).background(RoundedRectangle(cornerRadius: 100).fill(Color.gray))
    }
}

struct JamCamRow_Previews: PreviewProvider {
    static var previews: some View {
        JamCamsList()
            .previewLayout(.sizeThatFits)
    }
}
