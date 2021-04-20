//
//  AllJamCamsView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct AllJamCamsSheet: View {    
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                JamCamsList()
                Spacer()
            }
            .navigationBarTitle(Text("Search JamCams"), displayMode: .automatic)
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

struct AllJamCamsSheet_Previews: PreviewProvider {
    @State static private var isShowingAll = false

    static var previews: some View {
        AllJamCamsSheet(isPresented: $isShowingAll)
    }
}
