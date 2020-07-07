import CoreData

public class PasswordItem: NSManagedObject, Identifiable {
  @NSManaged public var id: UUID
  @NSManaged public var site: String
  @NSManaged public var username: String
  @NSManaged public var password: String
  @NSManaged public var createdAt: Date
  @NSManaged public var note: String
  @NSManaged public var lastUsed: Date
  @NSManaged public var isFavorite: Bool
}
