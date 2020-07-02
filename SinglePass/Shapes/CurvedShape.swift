import SwiftUI

struct CurvedShape: Shape {
  func path(in rect: CGRect) -> Path {
    let cornerRadius: CGFloat = 25
    var path = Path()

    path.move(to: .zero)
    path.addLine(to: CGPoint(x: rect.width, y: 0))
    path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
    path.addQuadCurve(to: CGPoint(x: 0, y: rect.height - cornerRadius), control: CGPoint(x: rect.midX, y: rect.height))
    
    return path
  }
}

struct CurvedShape_Previews: PreviewProvider {
    static var previews: some View {
        CurvedShape()
    }
}
