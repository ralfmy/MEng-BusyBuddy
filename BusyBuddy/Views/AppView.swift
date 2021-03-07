//
//  ContentView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 31/10/2020.
//
//  With help from:
// https://github.com/TreatTrick/Hide-TabBar-In-SwiftUI

import SwiftUI
import CoreData
import os.log

struct AppView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var placesManager: PlacesManager
    
    @State private var navigationBarHidden: Bool = false
    @State private var isShowingAll: Bool = false
    
    let impact = UIImpactFeedbackGenerator(style: .light)
    
    init() {
        UITabBar.appearance().barTintColor = UIColor(Color.tabBar)
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.white.opacity(0.3))
        UITabBar.appearance().tintColor = .white
        UITabBar.appearance().isOpaque = true
    }
    
    var body: some View {
        NavigationView {
            TabView(selection: $appState.tabSelection) {
                
                // Tab 1
                BookmarksGrid()
                .sheet(isPresented: $isShowingAll) {
                    AllPlacesSheet(isPresented: $isShowingAll)
                }
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                }
                .tag(Tab.bookmarks)
                
                // Tab 2
                MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                }
                .tag(Tab.map)
                
                // Tab 3
                SettingsView()
                .tabItem {
                    Image(systemName: "switch.2")
                }
                .tag(Tab.settings)
            }
            
            .navigationTitle(setNavigationBarTitle(tabSelection: appState.tabSelection))
            .navigationBarHidden(setNavigationBarHidden(tabSelection: appState.tabSelection))
            .navigationBarItems(leading: setNavigationBarItemLeading(tabSelection: appState.tabSelection), trailing: setNavigationBarItemTrailing(tabSelection: appState.tabSelection))
            .accentColor(.white)
        }
        .accentColor(.white)
    }
    
    private func setNavigationBarTitle(tabSelection: Tab) -> String {
        switch tabSelection {
        case .bookmarks:
            return "Bookmarks"
        case .map:
            return ""
        case .settings:
            return "Settings"
        }
    }
    
    private func setNavigationBarHidden(tabSelection: Tab) -> Bool {
        switch tabSelection {
        case .bookmarks:
            return false
        case .map:
            return true
        case .settings:
            return false
        }
    }
    
    @ViewBuilder private func setNavigationBarItemLeading(tabSelection: Tab) -> some View {
        switch tabSelection {
        case .bookmarks:
            SearchButton
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder private func setNavigationBarItemTrailing(tabSelection: Tab) -> some View {
        switch tabSelection {
        case .bookmarks:
            UpdateButton
        default:
            EmptyView()
        }
    }
    
    private var SearchButton: some View {
        Button(action: {
            impact.impactOccurred()
            isShowingAll.toggle()
        }) {
            Image(systemName: "magnifyingglass")
                .font(Font.title3.weight(.bold))
                .frame(width: 64, height: 64, alignment: .leading)
                .foregroundColor(.appGreyDarkest)
        }
    }
    
    private var UpdateButton: some View {
        Button(action: {
            impact.impactOccurred()
            self.placesManager.updateBookmarksScores()
        }) {
            Image(systemName: "arrow.clockwise")
                .font(Font.title3.weight(.bold))
                .frame(width: 64, height: 64, alignment: .trailing)
                .foregroundColor(.appGreyDarkest)
        }
    }
}

extension AppView {
    enum Tab: Hashable {
        case bookmarks
        case map
        case settings
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
