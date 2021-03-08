//
//  SettingsView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/02/2021.
//

import SwiftUI

struct SettingsView: View {
//    let columns: [GridItem] = [GridItem(.flexible(), spacing: 12, alignment: .leading), GridItem(.flexible(), spacing: 12, alignment: .trailing)]
    
    private let models: [String: ModelType] = ["TuriCreate Classifier": ModelType.tcv1,
                                               "TuriCreate Classifier pre": ModelType.tcv2,
                                               "TuriCreate Classifier pre + aug": ModelType.tcv3,
                                               "Create ML Classifier v6": ModelType.cmlv6,
                                               "YOLOv3": ModelType.yolo,
                                               "YOLOv3Tiny": ModelType.yolotiny]
        
    var body: some View {
        VStack {
            List {
                Section(header: Text("ML Model")) {
                    ForEach(Array(self.models.keys), id: \.self) { displayName in
                        ModelSelectionView(displayName: displayName, modelType: self.models[displayName]!)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .overlay(
                VStack {
                    Spacer()
                    Text("Powered by TfL Open Data")
                             .font(.caption2)
                             .fontWeight(.medium)
                             .foregroundColor(.gray)
                             .padding()
                }
            )
        }
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
            Image(systemName: setIcon()).font(.title2).foregroundColor(setForegroundColour())
            Spacer().frame(width: 10)
            Text(displayName).font(.callout).fontWeight(.medium)
        }
        .foregroundColor(Color.appGreyDarkest)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .leading)
//        .padding(.top, 8).padding(.bottom, 8).padding(.leading, 12).padding(.trailing, 12)
//        .background(setBackgroundColour())
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
            return Color.appBlue
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
