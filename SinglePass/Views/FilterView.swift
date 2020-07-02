import SwiftUI

struct FilterView: View {
  var filter: Filter
  @Binding var isSelected: Bool
  var onSelect: ((Filter) -> ()) = { _ in }

  var body: some View {
    ZStack(alignment: .bottom) {
      Text(filter.rawValue)
        .layoutPriority(1)
        .foregroundColor(isSelected ? .text : .gray)
        .padding(5)

      if isSelected {
        Rectangle()
          .frame(width: 50, height: 3)
          .foregroundColor(.accent)
          .cornerRadius(2)
          .transition(.scale)
      }
    }
    .padding().onTapGesture {
      onSelect(filter)
    }
  }
}

struct FilterView_Previews: PreviewProvider {
  static var previews: some View {
    FilterView(filter: .Passwords, isSelected: .constant(true))
  }
}
