import CoreData

public class NoteItem: NSManagedObject, Identifiable {
  @NSManaged public var id: UUID
  @NSManaged public var name: String
  @NSManaged public var content: String
  @NSManaged public var isFavorite: Bool
  @NSManaged public var createdAt: Date
  @NSManaged public var lastUsed: Date
}
