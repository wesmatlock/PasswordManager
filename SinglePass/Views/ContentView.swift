import SwiftUI

struct ContentView: View {
  @EnvironmentObject private var authManager: AuthenticationManager

  @State private var showMenu = false

  var body: some View {
    ZStack{
      if authManager.isLoggedIn {
        VStack {
          NavBar(showMenu: $showMenu)
          HomeView()
        }
      }
      else {
        AuthenticationView()
      }
    }.edgesIgnoringSafeArea(.top)
    .background(Color.background)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    let auth = AuthenticationManager()
    auth.isLoggedIn = true
    return ContentView().environmentObject(auth)
  }
}
