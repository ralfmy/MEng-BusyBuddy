//
//  Main.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 07/03/2021.
//
//  With help from:
//  https://peterfriese.dev/ultimate-guide-to-swiftui2-application-lifecycle/
//  https://swiftwithmajid.com/2020/08/19/managing-app-in-swiftui/
//  https://swiftwithmajid.com/2020/08/26/managing-scenes-in-swiftui/

import SwiftUI

@main
struct BusyBuddy: App {
    @Environment(\.scenePhase) var scenePhase

    @StateObject var appState: AppState = AppState()
    @StateObject var placesModel: PlacesModel = PlacesModel()
    
    var body: some Scene {
        WindowGroup {
            AppView().environmentObject(appState).environmentObject(placesModel)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                self.placesModel.updateBookmarksScores()
            default:
                break;
            }
        }
    }
}
