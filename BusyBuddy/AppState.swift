//
//  AppState.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/01/2021.
//
//  With help from:
//  https://nalexn.github.io/swiftui-deep-linking/


import Foundation

public class AppState: ObservableObject {
    @Published var tabSelection: AppView.Tab = .bookmarks
    @Published var placeSelectionId: String?
}