import SwiftUI

struct FormHeader: View {
  @Binding var showDetails: Bool
  @Binding var formType: FormType

  var body: some View {
    let imageName = "https://www.amazon.com".getImageName()

    return HStack {

      Button(action: {
        HapticFeedback.generate()
        withAnimation(.easeInOut) {
          showDetails.toggle()
        }
      }) {
        Image(systemName: "chevron.left")
          .imageScale(.large)
          .foregroundColor(.text)
      }

      Picker("", selection: $formType) {
        Text(FormType.Password.rawValue).tag(FormType.Password)
        Text(FormType.Note.rawValue).tag(FormType.Note)
      }.pickerStyle(SegmentedPickerStyle())
      .background(Color.background)
      .padding()

      Image(imageName)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 40, height: 40)
        .foregroundColor(.gray)

    }.padding()
    .padding(.top)
    .frame(maxWidth: .infinity)
    .frame(height: 100)
    .background(Color.background)
    .shadow(color: Color.darkShadow, radius: 5, x: 0, y: 5)
  }
}

struct FormHeader_Previews: PreviewProvider {
  static var previews: some View {
    FormHeader(showDetails: .constant(false), formType: .constant(FormType.Note) )

  }
}
