//
//  BusyIcon.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/11/2020.
//

import SwiftUI

struct BusyIcon: View {
    var busyScore: BusyScore
    let size: CGFloat
    let coloured: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle().fill(setBusyBackgroundColour()).frame(width: size, height: size)
            Circle().fill(setBusyForegroundColour()).frame(width: setInnerSize(), height: setInnerSize())
        }
    }
    
    private func setBusyForegroundColour() -> Color {
        if self.coloured {
            switch self.busyScore.score {
            case .notbusy:
                return Color.busyGreenDarker
            case .busy:
                return Color.busyPinkDarker
            case .unsure:
                return Color.busyYellowDarker
            default:
                return Color.busyGreyDarker
            }
        } else {
            return Color.white.opacity(0.4)
        }
        
    }
    
    private func setBusyBackgroundColour() -> Color {
        if self.coloured {
            switch self.busyScore.score {
            case .notbusy:
                return Color.busyGreenLighter
            case .busy:
                return Color.busyPinkLighter
            case .unsure:
                return Color.busyYellowLighter
            default:
                return Color.busyGreyLighter
            }
        } else {
            return Color.white.opacity(0.4)
        }
    }
    
    private func setInnerSize() -> CGFloat {
        switch self.busyScore.score {
        case .none:
            return 0
        case .notbusy:
            return 0.5 * size
        case .busy:
            return 0.8 * size
        case .unsure:
            return 0
        }
    }
}

struct BusyIcon_Previews: PreviewProvider {
    static var previews: some View {
        BusyIcon(busyScore: BusyScore(score: .none), size: 75, coloured: true)
    }
}
