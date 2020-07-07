import SwiftUI

struct PasswordGeneratorView: View {

  @Binding var generatedPassword: String

  @State private var password = ""
  @State private var lowercase = true
  @State private var uppercase = false
  @State private var specialCharacters = true
  @State private var digits = false
  @State private var length: CGFloat = 6

  var body: some View {
    VStack(spacing: 30) {
      VStack(spacing: 30) {
        Text("Generate password").font(.title).bold()

        Group {
          SharedTextfield(value: self.$password, header: "Generated Password", placeholder: "Your new password", errorMessage: "", showUnderline: false, onEditingChanged: { flag in
          }).padding()
        }.background(Color.background)
        .cornerRadius(10).neumorphic()

        VStack(spacing: 10){
          Toggle(isOn: $lowercase) {
            Text("Lowercase")
          }.toggleStyle(CustomToggleStyle())

          Toggle(isOn: $uppercase) {
            Text("Uppercase")
          }.toggleStyle(CustomToggleStyle())

          Toggle(isOn: $specialCharacters) {
            Text("Special Characters")
          }.toggleStyle(CustomToggleStyle())

          Toggle(isOn: $digits) {
            Text("Digits")
          }.toggleStyle(CustomToggleStyle())

          Slider(value: $length, in: 1...30, step: 1)
            .accentColor(Color.accent)

        }.padding()
        .background(Color.background)
        .cornerRadius(10)
        .neumorphic()

      }.padding(.horizontal)
      .frame(maxHeight: .infinity)
      .background(Color.background)
      .edgesIgnoringSafeArea(.all)
    }
  }
}

struct PasswordGeneratorView_Previews: PreviewProvider {
  static var previews: some View {
    PasswordGeneratorView(generatedPassword: .constant(""))
  }
}
