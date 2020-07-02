import SwiftUI

struct NavBar: View {

  @Binding var showMenu: Bool

  @State private var searchTerm = ""

  var title: String = "Vault"
  var showSearchField = true

  var body: some View {
    ZStack(alignment: .bottom) {
      HStack {

        Rectangle()
          .foregroundColor(.clear)
          .frame(width: 20, height: 30, alignment: .center)
          .padding(.leading, 10)

        Spacer()
        Text(title)
          .font(.title)
          .bold()
          .foregroundColor(.white)

        Spacer()
        Image(systemName: "line.horizontal.3")
          .resizable(capInsets: EdgeInsets(), resizingMode: .stretch)
          .frame(width: 20, height: 30, alignment: .center)
          .foregroundColor(.white)
          .padding(.trailing, 10)
      }.padding(.bottom, 20)
      .frame(maxWidth: .infinity)
      .frame(height: showSearchField ? 140 : 90, alignment: showSearchField ? .center : .bottom)
      .background(Color.accent)
      .clip(shouldCurve: showSearchField)

      if showSearchField {
        LCSearchField(value: $searchTerm)
          .padding()
          .offset(y: 15)
      }
    }
  }
}

struct NavBar_Previews: PreviewProvider {
  static var previews: some View {
    NavBar(showMenu: .constant(true)).previewLayout(.sizeThatFits)
  }
}

