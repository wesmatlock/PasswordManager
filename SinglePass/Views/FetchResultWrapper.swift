import SwiftUI
import CoreData

struct FetchResultWrapper<Object, Content>: View where Object: NSManagedObject, Content: View {

  let content: ([Object]) -> Content
  let request: FetchRequest<Object>

  init(predicate: NSPredicate = NSPredicate(value: true),
       sortDescriptors: [NSSortDescriptor] = [],
       @ViewBuilder content: @escaping ([Object]) -> Content) {

    self.content = content
    self.request = FetchRequest( entity: Object.entity(), sortDescriptors: sortDescriptors, predicate: predicate)
  }

  var body: some View {
    content(request.wrappedValue.map({$0}))
  }

}
