//
//  SearchBar.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 01/03/2021.
//
//  With help from:
//  https://www.appcoda.com/swiftui-search-bar/

import SwiftUI

struct SearchBar: View {
    
    @Binding var query: String
    @State private var isEditing = false
        
    var body: some View {
        HStack {
            TextField("Search", text: $query)
                .padding(12).padding(.leading, 28)
                .background(Color.busyGreyLighter)
                .cornerRadius(12)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.appGreyDarker)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 12)
                        if self.isEditing && !self.query.isEmpty {
                            Button(action: {
                                self.isEditing = false
                                self.query = ""
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.appGreyDarker)
                                    .padding(.trailing, 12)
                            }
                        }
                    }
                )
                .onTapGesture {
                    self.isEditing = true
                }
        }
        .padding(.leading).padding(.trailing)
    }
    
}
