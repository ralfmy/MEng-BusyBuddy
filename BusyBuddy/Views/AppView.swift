//
//  ContentView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 31/10/2020.
//
//  With help from
//  https://www.hackingwithswift.com/quick-start/swiftui/introduction-to-using-core-data-with-swiftui 

import SwiftUI
import CoreData
import os.log

struct AppView: View {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "AppView")

    @EnvironmentObject var placesManager: PlacesManager
    @EnvironmentObject var bookmarksManager: BookmarksManager
    
    @State private var tabSelection: Int = 0
    @State private var navigationBarHidden: Bool = false
    @State private var firstLoad: Bool = true
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
            TabView(selection: $tabSelection) {
                
                // Tab 1
                BookmarksGrid()
                .sheet(isPresented: $isShowingAll) {
                    AllPlacesSheet(isPresented: $isShowingAll).environmentObject(bookmarksManager)
                }
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                }
                .onAppear {
                    if firstLoad {
                        updateScores()
                        firstLoad = false
                    }
                }
                .tag(0)
                
                // Tab 2
                MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                }
                .tag(1)
            }
            
            .navigationTitle(setNavigationBarTitle(tabSelection: tabSelection))
            .navigationBarHidden(setNavigationBarHidden(tabSelection: tabSelection))
            .navigationBarItems(leading: SearchButton, trailing: UpdateButton)
            .accentColor(.white)
        }
        .accentColor(.white)
    }
    
    private func setNavigationBarTitle(tabSelection: Int) -> String {
        switch tabSelection {
        case 0:
            return "Bookmarks"
        case 1:
            return ""
        default:
           return ""
        }
    }
    
    private func setNavigationBarHidden(tabSelection: Int) -> Bool {
        switch tabSelection {
        case 0:
            return false
        case 1:
            return true
        default:
            return true
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
            updateScores()
        }) {
            Image(systemName: "arrow.clockwise")
                .font(Font.title3.weight(.bold))
                .frame(width: 64, height: 64, alignment: .trailing)
                .foregroundColor(.appGreyDarkest)
        }
    }
    
    private func updateScores() {
        bookmarksManager.updateScores()
    }
}

struct ContentView_Previews: PreviewProvider {
    static let persistentContainer = PersistenceManager(.memory).container
    static let managedObjectContext = persistentContainer.viewContext
    static let store = PlacesDataManager(persistentContainer: persistentContainer, managedObjectContext: managedObjectContext)
    static let bookmarks = BookmarksManager()
    
    static var previews: some View {
        AppView().environmentObject(store).environmentObject(bookmarks)
    }
}
