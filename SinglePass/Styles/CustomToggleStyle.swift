import SwiftUI

struct CustomToggleStyle: ToggleStyle {

  var onColor: Color = .background
  var offColor: Color = .darkerAccent
  var size: CGFloat = 40

  func makeBody(configuration: Self.Configuration) -> some View {
    HStack {
      configuration.label
      Spacer()

      Button(action: {
        configuration.isOn.toggle()
      }) {
        if configuration.isOn {
          ZStack {
            Circle()
              .fill(Color.background)
              .frame(width: size, height: size)

            Image(systemName: "power")
              .resizable(capInsets: EdgeInsets(), resizingMode: .stretch)
              .frame(width: 20, height: 20, alignment: .center)
              .foregroundColor(.accent)
          }.innerShadow(radius: 1, colors: (.darkShadow, .lightShadow))
        }
        else {
          ZStack {
            Circle().frame(width: size, height: size, alignment: .center)
              .foregroundColor(.background)

            Image(systemName: "power")
              .resizable()
              .frame(width: 20, height: 20)
              .foregroundColor(.gray)
          }.cornerRadius(size / 2).neumorphic()
        }
      }
    }
  }
}

struct CustomToggleStyle_Previews: PreviewProvider {
  static var previews: some View {
    /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
  }
}
