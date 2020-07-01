import SwiftUI

struct AccountCreationView: View {

  @Binding var showLogin: Bool

  @State private var email = ""
  @State private var password = ""
  @State private var confirmedPassword = ""

  @State private var formOffset: CGFloat = 0
  @State private var showAlert = false

  @EnvironmentObject private var authManager: AuthenticationManager

  fileprivate func goToLoginButton() -> some View {
    return Button(action: {
      authManager.email = ""
      authManager.password = ""
      authManager.confirmedPassword = ""

      withAnimation(.spring() ) {
        self.showLogin.toggle()
      }
    }) {
      HStack {
        Text("Login")
          .accentColor(Color.darkerAccent)
        Image(systemName: "arrow.right.square.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 20)
          .foregroundColor(Color.darkerAccent)

      }
    }
  }

  fileprivate func createContent() -> some View{
    VStack {
      Image("singlePass-dynamic").resizable().aspectRatio(contentMode: .fit) .frame(height: 30)
        .padding(.bottom)
      VStack(spacing: 10) {
        Text("Create Account").font(.title).bold()
        VStack(spacing: 30) {

          SharedTextfield(value: $authManager.email,header: "Email",
                          placeholder: "Your primary email",
                          errorMessage: authManager.emailValidation.message)

          PasswordField(value: $authManager.password,header: "Password",
                        placeholder: "Make sure it's string",
                        errorMessage: authManager.passwordValidation.message,
                        trailingIconName: "doc.on.clipboard.fill", isSecure: true)

          PasswordField(value: $authManager.confirmedPassword,
                        header: "Confirm Password",
                        placeholder: "Must match the password",
                        errorMessage: authManager.confirmedPasswordValidation.message,
                        trailingIconName: "doc.on.clipboard.fill",
                        isSecure: true)

          Text(self.authManager.similarityValidation.message).foregroundColor(Color.red)

        }
        LCButton(text: "Sign up", backgroundColor: authManager.canSignup ? Color.accent : Color.gray ) {
          showAlert = !self.authManager.createAccount()
        }
        .disabled(!self.authManager.canSignup)
        .alert(isPresented: $showAlert) { () -> Alert in
          Alert(title: Text("Error"),
                message: Text("Opps! Seems like thre's already an account associated with this device. You need to login instead."),
                dismissButton: .default(Text("Ok")))
        }

      }.modifier(FormModifier()).offset(y: self.formOffset)

      goToLoginButton()
    }
  }

  var body: some View {

    SubscriptionView(content: createContent(), publisher: NotificationCenter.keyboardPublisher) { frame in
      withAnimation {
        self.formOffset = frame.height > 0 ? -200 : 0
      }
    }
  }
}

struct SignupView_Previews: PreviewProvider {
  static var previews: some View {
    AccountCreationView(showLogin: .constant(false))
  }
}
