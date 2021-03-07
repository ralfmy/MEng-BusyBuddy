//
//  AllPlacesView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct AllPlacesSheet: View {    
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                PlacesList()
                Spacer()
            }
            .navigationBarTitle(Text("All Places"), displayMode: .automatic)
            .navigationBarItems(trailing: DoneButton)
        }.accentColor(.white)
    }
    
    private var DoneButton: some View {
        Button(action: {
            isPresented = false
        }) {
            Text("Done").foregroundColor(.appGreyDarkest)
        }
    }
}

struct AllPlacesSheet_Previews: PreviewProvider {
    @State static private var isShowingAll = false

    static var previews: some View {
        AllPlacesSheet(isPresented: $isShowingAll)
    }
}
