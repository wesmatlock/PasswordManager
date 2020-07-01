import SwiftUI

struct HapticFeedback {
    public static func generate(){
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}
