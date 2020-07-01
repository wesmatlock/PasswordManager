import SwiftUI
import CryptoKit
import LocalAuthentication

struct LoginView: View {

  @Binding var showCreateAccount: Bool

  @State private var email = ""
  @State private var password = ""
  @State private var formOffset: CGFloat = 0

  @State private var showAlert = false
  @State private var showResetPasswordPopup = false

  @EnvironmentObject private var authManager: AuthenticationManager

  fileprivate func createAccountButton() -> some View {
    return Button(action: {
      authManager.email = ""
      authManager.password = ""
      withAnimation(.spring()) {
        self.showCreateAccount.toggle()
      }
    }) {
      HStack {
        Image(systemName: "arrow.left.square.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 20)
          .foregroundColor(Color.darkerAccent)
        Text("Create account")
          .accentColor(Color.darkerAccent)
      }
    }
  }

  private func resetPassordPopupView() -> some View {
    ZStack(alignment: .topTrailing) {
      VStack(spacing: 40) {
        Text("Set your new password")
          .bold()
          .foregroundColor(.accent)
        PasswordField(value: self.$authManager.resetPassword, header: "New Password", placeholder: "New password goes here...", errorMessage: authManager.resetPasswordValidation.message , isSecure: true)

        LCButton(text: "Save", backgroundColor: self.authManager.resetPasswordValidation.success ? Color.accent : Color.gray) {
          self.showResetPasswordPopup = !self.authManager.saveResetPassword()
        }.disabled(!self.authManager.resetPasswordValidation.success)
      }.padding(.horizontal).frame(maxWidth: .infinity, maxHeight: 280)
      .background(Color.background)
      .cornerRadius(20)

      Button(action: {
        self.showResetPasswordPopup.toggle()
      }) {
        Image(systemName: "xmark")
          .imageScale(.large)
          .padding()
          .foregroundColor(.gray)
      }

    }
  }

  fileprivate func createResetPasswordButton() -> some View {
    return Button(action: {
      withAnimation(.spring()) {
        self.showCreateAccount.toggle()
      }
    }) {
      HStack {
        Image(systemName: "arrow.counterclockwise")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 20)
          .foregroundColor(.darkerAccent)
        Text("Reset Password")
          .accentColor(.darkerAccent)
      }
    }
  }

  fileprivate func createBiometricButton(action: @escaping () -> Void) -> some View {
    Button(action: action) {
      if authManager.biometryType == LABiometryType.faceID {
        BiometricButtonLabel(icon: "faceid", text:  "Use face ID")
      }
      if authManager.biometryType == LABiometryType.touchID {
        BiometricButtonLabel()
      }
    }
  }

  fileprivate func createContent() -> some View {
    return VStack {
      Image("singlePass-dynamic").resizable().aspectRatio(contentMode: .fit) .frame(height: 30)
        .padding(.bottom)

      VStack(spacing: 30) {
        Text("Login").font(.title).bold()
        VStack(spacing: 30) {
          SharedTextfield(value: self.$authManager.email, header: "Email" , placeholder: "Your email",errorMessage: authManager.emailValidation.message)
          PasswordField(value: self.$authManager.password, header: "Master Password",
                        placeholder: "Master password goes here...",
                        errorMessage: authManager.passwordValidation.message, isSecure: true)

          LCButton(text: "Login", backgroundColor: self.authManager.canLogin ? Color.accent : Color.gray) { }
            .disabled(!authManager.canLogin)
            .alert(isPresented: $showAlert) {
              if authManager.hasAccount(){
                return Alert(title: Text("Error"),
                             message: Text("Oops!The credentials you've provided are not correct, try again."),
                             dismissButton: Alert.Button.default(Text("Ok")) )
              }
              return Alert(title: Text("Error"),
                           message: Text("Oops! You don't have an account yet, sign uo instead."),
                           dismissButton: Alert.Button.default(Text("Ok")) )
            }
          if self.authManager.hasAccount() {
            createBiometricButton {
              authManager.loginWithBiometric()
            }
          }
        }.modifier(FormModifier()).offset(y: self.formOffset)
        createAccountButton()
        if authManager.hasAccount() {
          Text("OR").bold()
          createResetPasswordButton()
        }
      }
    }
  }

  private func biometricPopupView() -> some View {
    ZStack(alignment: .topTrailing) {
      VStack(spacing: 20) {
        Text(authManager.biometricResult == .failure ? "Failed" : "Authentication required")
          .bold()
          .foregroundColor(self.authManager.biometricResult == .failure ? .red : .accent)
        createBiometricButton {
          authManager.authenticateWithBiometric()
        }
      }.frame(width: 250, height: 200)
      .background(Color.background)
      .cornerRadius(20)

      Button(action: {
        showResetPasswordPopup.toggle()
      }) {
        Image(systemName: "xmark")
          .imageScale(.large)
          .padding()
          .foregroundColor(.gray)
          .opacity(0.6)
      }
    }
  }

  var body: some View {

    ZStack {
      SubscriptionView(content: createContent(), publisher: NotificationCenter.keyboardPublisher) { frame in
        withAnimation {
          self.formOffset = frame.height > 0 ? -150 : 0
        }
      }

      VStack {
        if showResetPasswordPopup {
          showPopups()
            .offset(y: formOffset)
            .transition(.scale)
        }
      }.frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.black.opacity(0.6))
      .opacity(showResetPasswordPopup ? 1 : 0)
      .animation(.spring())
    }
  }

  func showPopups() -> some View {
    switch authManager.biometricResult {
    case .success:
      return AnyView(resetPassordPopupView().padding())
    default:
      return AnyView(biometricPopupView())
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView(showCreateAccount: .constant(false))
  }
}
