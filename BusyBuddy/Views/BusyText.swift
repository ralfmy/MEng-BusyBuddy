//
//  BusyText.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/11/2020.
//

import SwiftUI

struct BusyText: View {    
    let busyScore: BusyScore
    let font: Font
    
    var body: some View {
        Text(busyScore.scoreAsString())
            .font(font)
            .fontWeight(.bold)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(alignment: .leading)
            .foregroundColor(busyScore.score == .none ? Color.appGreyDarker.opacity(0.8) : Color.white.opacity(0.8))
    }
}

struct BusyText_Previews: PreviewProvider {
    static var previews: some View {
        BusyText(busyScore: BusyScore(), font: .subheadline)
    }
}
