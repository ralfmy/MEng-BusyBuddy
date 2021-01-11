//
//  JamCamAnnotation.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 07/01/2021.
//

import SwiftUI

struct JamCamAnnotation: View {
    var body: some View {
        Image(systemName: "video.fill")
            .font(.subheadline)
            .padding(16)
            .foregroundColor(.white)
            .background(Circle().strokeBorder(Color.white.opacity(0.8), lineWidth: 3).background(Circle().fill(Color.appBlue)))
    }
}

struct JamCamAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        JamCamAnnotation()
            .previewLayout(.sizeThatFits)
    }
}
