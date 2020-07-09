import SwiftUI

struct HomeView: View {

  @State var showEditFormView = false

  @ObservedObject var coredataManager = CoreDataManager.shared

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      VStack {
        HeaderView { filter in }
        createList()
      }
      createFloatingButton()
    }
  }

  private func createList() -> some View {
    List {
      if coredataManager.showPasswords {
        createPasswordsSection()
      }
      if coredataManager.showNotes {
        createNotesSection()
      }
    }
    .onAppear {
      UITableView.appearance().backgroundColor = UIColor(named: "bg")
      UITableView.appearance().separatorColor = .clear
      UITableView.appearance().showsVerticalScrollIndicator = false
    }

  }

  private func createPasswordsSection() -> some View {

    FetchResultWrapper(predicate: self.coredataManager.passwordPredicate, sortDescriptors: [self.coredataManager.sortDescriptor]) { (passwords: [PasswordItem]) in

      if !passwords.isEmpty {
        Section(header: SectionTitle(title: "Passwords")
        ) {
          ForEach(passwords.map { PasswordViewModel(passwordItem: $0) } ) { password in
            RowItem(passwordModel: password).listRowBackground(Color.background)
          }
        }
      }
    }
  }

  private func createNotesSection() -> some View {

    FetchResultWrapper(predicate: self.coredataManager.notePredicate, sortDescriptors: [self.coredataManager.sortDescriptor]) { (notes: [NoteItem]) in

      if !notes.isEmpty {
        Section(header: SectionTitle(title: "Notes")
        ) {
          ForEach(notes.map { NoteViewModel(noteItem: $0) } ) { note in
            RowItem(noteModel: note).listRowBackground(Color.background)
          }
        }
      }
    }
  }

  private func createFloatingButton() -> some View {
    Button(action: {
      HapticFeedback.generate()
      showEditFormView.toggle()
    }) {
      Image(systemName: "plus")
        .resizable()
        .frame(width: 20, height: 20)
        .foregroundColor(.text)
        .padding()
        .background(Color.background)
        .cornerRadius(35)
        .neumorphic()
    }.padding(30)
    .sheet(isPresented: $showEditFormView) {
      createEditFormView()
    }
  }

  fileprivate func createEditFormView() -> some View {
    EditFormView(showDetails: $showEditFormView)
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
