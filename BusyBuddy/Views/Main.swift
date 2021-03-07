//
//  Main.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 07/03/2021.
//
//  With help from:
//  https://peterfriese.dev/ultimate-guide-to-swiftui2-application-lifecycle/
//  https://swiftwithmajid.com/2020/08/19/managing-app-in-swiftui/

import SwiftUI

@main
struct BusyBuddy: App {
    @StateObject var appState: AppState = AppState()
    @StateObject var placesModel: PlacesModel = PlacesModel()
    
    var body: some Scene {
        WindowGroup {
            AppView().environmentObject(appState).environmentObject(placesModel)
        }
    }
}
