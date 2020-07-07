import SwiftUI

extension View {
  func innerShadow(radius: CGFloat, colors: (dark: Color, light: Color)) -> some View {
    overlay(
      Circle()
        .stroke(colors.dark, lineWidth: 4)
        .blur(radius: radius)
        .offset(x: radius, y: radius)
        .mask(Circle().fill(LinearGradient(colors.dark, .clear)))
    )
    .overlay(
      Circle()
        .stroke(colors.light, lineWidth: 8)
        .blur(radius: radius)
        .offset(x: -radius, y: -radius)
        .mask(Circle().fill(LinearGradient(.clear, colors.dark)))
    )

  }
}
