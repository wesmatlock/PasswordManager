import SwiftUI

struct BiometricButtonLabel: View {

  var icon = "touchId"
  var text = "Use touchId"

  var body: some View {
    VStack {
      Image("touchId")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 40, height: 40)
      Text("Use touch ID")
    }.foregroundColor(.accent)
  }
}

struct BiometricButtonLabel_Previews: PreviewProvider {
  static var previews: some View {
    BiometricButtonLabel()
  }
}
