import SwiftUI

struct EditFormView: View {
  @Binding var showDetails: Bool

  @State private var username = ""
  @State private var password = ""
  @State private var website = ""
  @State private var passwordNote = ""

  @State private var noteName = ""
  @State private var noteContent = ""
  @State private var favoriteImage = "heart"
  @State private var formType = FormType.Password

  @State private var formOffsetY: CGFloat = 0

  var body: some View {

    SubscriptionView(content: createBodyContent(),
                     publisher: NotificationCenter.keyboardPublisher) { rect in
      withAnimation {
        self.formOffsetY = rect.height > 0 ? -150 : 0
      }
    }
  }

  fileprivate func createBodyContent() -> some View {
    VStack {
      FormHeader(showDetails: $showDetails, formType: $formType)
      ScrollView {
        VStack {
          if formType == .Password {
            createPasswordForm()
          }
          else {
            createNoteForm()
          }
          HStack(spacing: 20) {
            createSaveButton()
            createHeartButton()
          }.padding(.horizontal)
        }
      }
    }.background(Color.background)
    .cornerRadius(20)
    .padding()
    .padding(.top, 40)
    .neumorphic()
  }

  fileprivate func createNoteForm() -> some View {

    VStack(spacing: 40) {
      SharedTextfield(value: $noteName, header: "Title", placeholder: "Your note title goes here")
      SharedTextfield(value: $noteContent, header: "Note", placeholder: "Your can write anything here", showUnderline: false)
    }.padding()
  }

  fileprivate func createPasswordForm() -> some View {
    VStack(spacing: 40) {
      SharedTextfield(value: $username)

      VStack(alignment: .leading) {
        PasswordField(value: $password, header: "Password", placeholder: "Make sure the password is secure")
        Button(action: {

        }) {
          Text("Genereate password")
            .foregroundColor(.accent)
        }
      }
      SharedTextfield(value: $website, header: "Website", placeholder: "https://")
      SharedTextfield(value: $passwordNote, header: "Note", placeholder: "You can write anything here ... ")
    }.padding()
  }

  fileprivate func createSaveButton() -> LCButton {
    return LCButton(text: "Save", backgroundColor: .accent) {
      switch formType {
      case .Password:
        break
      case .Note:
        break
      }
    }
  }

  fileprivate func createHeartButton() -> some View {
    Button(action: {

    }) {
      Image(systemName: favoriteImage)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 30)
        .foregroundColor(favoriteImage == "heart" ? .gray : .orange)
    }
  }
}

struct EditFormView_Previews: PreviewProvider {
  static var previews: some View {
    EditFormView(showDetails: .constant(true))
  }
}
