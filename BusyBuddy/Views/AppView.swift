//
//  ContentView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/11/2020.
//
//  https://github.com/TreatTrick/Hide-TabBar-In-SwiftUI

import SwiftUI

struct AppView: View {
    
    init() {
        UITabBar.appearance().barTintColor = UIColor(Color.appBlue)
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.white.opacity(0.3))
        UITabBar.appearance().tintColor = .white
    }
    
    var body: some View {
        TabView {
            PlacesView().tabItem {
                Image(systemName: "square.grid.2x2.fill").font(.system(size: 20))
            }
            MapView().tabItem {
                Image(systemName: "map.fill")
            }
        }.accentColor(.white)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
