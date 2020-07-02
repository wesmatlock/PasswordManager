import SwiftUI

struct LCSearchField: View {

  @Binding var value: String
  var onEditingChanged: ((Bool)-> Void) = { _ in }
  var onCommit: (() -> ()) = {}

  var body: some View {

    HStack {
      Image(systemName: "magnifyingglass")
        .imageScale(.large)
        .padding(.leading, 10)

      TextField("Search ...", text: $value, onEditingChanged: onEditingChanged, onCommit: {
        self.onCommit()
      }).padding(.vertical, 10)
    }
    .foregroundColor(.gray)
    .background(Color.background)
    .cornerRadius(13)
    .padding()
    .frame(height: 45)
    .shadow(color: .darkShadow, radius: 5, x:0, y: 5)
  }
}

struct LCSearchField_Previews: PreviewProvider {
    static var previews: some View {
        LCSearchField(value: .constant(""))
    }
}
