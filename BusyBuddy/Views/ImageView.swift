//
//  ImageView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/12/2020.
//

import SwiftUI
import os.log

struct ImageView: View {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "Image View")

    @Binding var isShowing: Bool
    
    let busyScore: BusyScore
    
    var body: some View {
        VStack(alignment: .center) {
            Image(uiImage: busyScore.image).padding(.bottom, 20)
            CloseButton
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        .background(Rectangle().fill(Color.black.opacity(0.8)))
        .opacity(self.isShowing ? 1 : 0)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.isShowing.toggle()
            }
        }
        .onAppear {
            self.logger.info("INFO: \(busyScore.count) people detected.")
        }
    }
    
    private var CloseButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.isShowing.toggle()
            }
        }) {
            Image(systemName: "xmark.circle.fill").font(.system(size: 40)).foregroundColor(Color.white.opacity(0.8))
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    @State static private var isShowing = true

    static var previews: some View {
        ImageView(isShowing: $isShowing, busyScore: BusyScore(id: ExamplePlace.place.id))
    }
}
