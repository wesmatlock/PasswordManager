import SwiftUI

struct FormModifier: ViewModifier {
        
     func body(content: Content) -> some View {
        content.padding()
                 .background(Color.background)
                             .cornerRadius(10)
                             .padding()
                            .neumorphic()
                             
               
       }
}

