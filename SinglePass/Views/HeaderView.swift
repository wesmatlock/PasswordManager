import SwiftUI

struct HeaderView: View {

  @State private var selectedFilter = Filter.AllItems

  var onSelect: ((Filter)->()) = { _ in }

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {

      HStack {

        ForEach(Filter.allCases, id: \.self) { filter in
          FilterView(filter: filter, isSelected: .constant(selectedFilter == filter)) { selected in
            withAnimation(.spring()) {
              self.selectedFilter = selected
            }
            self.onSelect(selected)
          }
        }
      }
    }
  }
}

struct HeaderView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      HeaderView()
    }
  }
}
