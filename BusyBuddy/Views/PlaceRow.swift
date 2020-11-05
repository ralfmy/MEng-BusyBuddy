//
//  PlaceItem.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//

import SwiftUI
import CoreML
import os.log

struct PlaceRow: View {
    var commonName: String
    var body: some View {
        Text(commonName)
    }
}

struct PlaceRow_Previews: PreviewProvider {
    static var previews: some View {
        PlaceRow(commonName: "Oxford St")
    }
}
