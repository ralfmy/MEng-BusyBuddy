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
    @Published var isSearching: Bool = false
    @Published var jamCamSelectionId: String?
    @Published var modelSelection: ModelType = ModelType(rawValue: UserDefaults(suiteName: "group.com.zcabrmy.BusyBuddy")!.integer(forKey: "model")) ?? ModelType.resnet
}
