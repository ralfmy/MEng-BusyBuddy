//
//  SettingsView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/02/2021.
//

import SwiftUI

struct SettingsView: View {
//    let columns: [GridItem] = [GridItem(.flexible(), spacing: 12, alignment: .leading), GridItem(.flexible(), spacing: 12, alignment: .trailing)]
        
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 10)
            Text("ML MODEL")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .frame(alignment: .leading)
                .padding(.bottom, 5)
            VStack {
                ModelSelectionView(displayName: "TuriCreate Classifier", modelType: ModelType.tcv1)
                ModelSelectionView(displayName: "TuriCreate Classifier pre", modelType: ModelType.tcv2)
                ModelSelectionView(displayName: "TuriCreate Classifier pre + aug", modelType: ModelType.tcv3)
                ModelSelectionView(displayName: "Create ML Classifier v6", modelType: ModelType.cmlv6)
                ModelSelectionView(displayName: "YOLOv3", modelType: ModelType.yolo)
                ModelSelectionView(displayName: "YOLOv3 Tiny", modelType: ModelType.yolotiny)
            }.padding(0)
            Spacer()
        }
        .padding(.leading).padding(.trailing)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct ModelSelectionView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var placesModel: PlacesModel
        
    var displayName: String
    var modelType: ModelType
    
    private let defaults = UserDefaults(suiteName: "group.com.zcabrmy.BusyBuddy")!

    
    var body: some View {
        HStack {
            Image(systemName: setIcon()).font(.title2)
            Text(displayName).font(.headline).fontWeight(.medium)
        }
        .foregroundColor(setForegroundColour())
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 40, alignment: .leading)
        .padding(.top, 8).padding(.bottom, 8).padding(.leading, 12).padding(.trailing, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(setBackgroundColour())
        )
        .onTapGesture {
            defaults.set(self.modelType.rawValue, forKey: "model")
            self.appState.modelSelection = self.modelType
            self.placesModel.updateModel()
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
        SettingsView()
    }
}
