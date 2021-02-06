//
//  SettingsView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/02/2021.
//

import SwiftUI

struct SettingsView: View {
    let columns: [GridItem] = [GridItem(.flexible(), spacing: 12, alignment: .leading), GridItem(.flexible(), spacing: 12, alignment: .trailing)]
        
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 10)
            Text("ML MODEL")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(alignment: .leading)
                .padding(.bottom, 5)
            LazyVGrid(columns: columns, alignment: .center, spacing: 16, pinnedViews: [])
            {
                ModelSelectionView(displayName: "TuriCreate Image Classifier", modelType: ModelType.classifier_tc)
                ModelSelectionView(displayName: "YOLO", modelType: ModelType.yolo)
            }
        }
        .padding(.leading).padding(.trailing)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct ModelSelectionView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var bookmarksManager: BookmarksManager
        
    var displayName: String
    var modelType: ModelType
    
    private let defaults = UserDefaults(suiteName: "group.com.zcabrmy.BusyBuddy")!

    
    var body: some View {
        HStack {
            Image(systemName: setIcon()).font(.title2)
            Text(displayName).font(.subheadline).fontWeight(.medium)
        }
        .foregroundColor(setForegroundColour())
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .padding(.top, 8).padding(.bottom, 8).padding(.leading, 12).padding(.trailing, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(setBackgroundColour())
        )
        .onTapGesture {
            defaults.set(self.modelType.rawValue, forKey: "model")
            self.appState.modelSelection = self.modelType
            self.bookmarksManager.updateModel()
        }
    }
    
    private func setIcon() -> String {
        if self.appState.modelSelection == self.modelType {
            return "checkmark.circle.fill"
        } else {
            return "circle"
        }
    }
    
    private func setForegroundColour() -> Color {
        if self.appState.modelSelection == self.modelType {
            return Color.white
        } else {
            return Color.appGreyDarkest
        }
    }
    
    private func setBackgroundColour() -> Color {
        if self.appState.modelSelection == self.modelType {
            return Color.appBlue
        } else {
            return Color.busyGreyLighter
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().previewLayout(.sizeThatFits)
    }
}
