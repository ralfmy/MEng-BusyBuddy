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
            case .low:
                return Color.busyGreenDarker
            case .medium:
                return Color.busyYellowDarker
            case.high:
                return Color.busyPinkDarker
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
            case .low:
                return Color.busyGreenLighter
            case .medium:
                return Color.busyYellowLighter
            case.high:
                return Color.busyPinkLighter
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
        case .low:
            return 0.5 * size
        case .medium:
            return 0.6 * size
        case .high:
            return 0.8 * size
        case .unsure:
            return 0
        default:
            return size
        }
    }
}

struct BusyIcon_Previews: PreviewProvider {
    static var previews: some View {
        BusyIcon(busyScore: BusyScore(count: -1), size: 75, coloured: true)
    }
}
