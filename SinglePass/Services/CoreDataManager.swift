import UIKit
import CoreData
import Combine

class CoreDataManager: ObservableObject {
  var context: NSManagedObjectContext

  static let shared = CoreDataManager(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)

  @Published var notePredicate = NSPredicate(value: true)
  @Published var passwordPredicate = NSPredicate(value: true)
  @Published var sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)

  @Published var searchTerm = ""

  @Published var showNotes = true
  @Published var showPasswords = true

  private var cancellableSet: Set<AnyCancellable> = []

  private init(context: NSManagedObjectContext) {
    self.context = context
  }

  func save() -> Bool {
    if context.hasChanges {
      do {
        try context.save()
        return true
      } catch let error {
        print("Error saving changed to the context parent store.: \(error.localizedDescription)")
        return false
      }
    }
    return true
  }

  func updateLastUsedPassword(with id: UUID) -> Bool {

    let request: NSFetchRequest<PasswordItem> = PasswordItem.fetchRequest() as! NSFetchRequest<PasswordItem>
    request.predicate = NSPredicate(format: "id = %@", id.uuidString)

    do {
      let results = try context.fetch(request)
      results[0].setValue(Date(), forKey: "lastUsed")
      return save()
    } catch let error {
      print(error)
    }

    return false
  }

  func setFavoritePassword(_ password: PasswordViewModel) -> Bool {

    let request: NSFetchRequest<PasswordItem> = PasswordItem.fetchRequest() as! NSFetchRequest<PasswordItem>
    request.predicate = NSPredicate(format: "id = %@", password.id.uuidString)

    let isFavorite = password.isFavorite ? 0 : 1
    do {
      let results = try context.fetch(request)
      results[0].setValue(isFavorite, forKey: "isFavorite")
      return save()
    } catch let error {
      print(error)
    }
    return false
  }

  func updateLastUsedNote(with id: UUID) -> Bool {

    let request: NSFetchRequest<NoteItem> = NoteItem.fetchRequest() as! NSFetchRequest<NoteItem>
    request.predicate = NSPredicate(format: "id = %@", id.uuidString)

    do {
      let results = try context.fetch(request)
      results.first?.setValue(Date(), forKey: "lastUsed")
      return save()
    } catch let error {
      print(error)
    }

    return false
  }

  func setFavoriteNote(_ note: NoteViewModel) -> Bool {

    let request: NSFetchRequest<NoteItem> = NoteItem.fetchRequest() as! NSFetchRequest<NoteItem>
    request.predicate = NSPredicate(format: "id - %@", note.id.uuidString)

    let isFavorite = note.isFavorite ? 0 : 1

    do {
      let results = try context.fetch(request)
      results.first?.setValue(isFavorite, forKey: "isFavorite")
      return save()
    } catch let error {
      print(error)
    }

    return false
  }

  func performSearch() {

    let passwordSearchPublisher = $searchTerm.debounce(for: 05, scheduler: RunLoop.main)
      .removeDuplicates()
      .map { term in
        return term.isEmpty ? NSPredicate.init(value: true) : NSPredicate(format: "name CONATAINS[c] %@", term)
      }.eraseToAnyPublisher()

    let noteSearchPublisher = $searchTerm.debounce(for: 05, scheduler: RunLoop.main)
      .removeDuplicates()
      .map { term in
        return term.isEmpty ? NSPredicate.init(value: true) : NSPredicate(format: "name CONATAINS[c] %@", term)
      }.eraseToAnyPublisher()

    Publishers.CombineLatest(passwordSearchPublisher, noteSearchPublisher)
      .receive(on: DispatchQueue.main)
      .sink {[unowned self] passwordPred, notePred in
        self.passwordPredicate = passwordPred
        self.notePredicate = notePred
      }.store(in: &cancellableSet)
  }

  func applyFilter(_ filter: Filter) {

    sortDescriptor = NSSortDescriptor(keyPath: \PasswordItem.createdAt, ascending: false)
    passwordPredicate = NSPredicate(value: true)
    notePredicate = NSPredicate(value: true)

    switch filter {
    case .MostUsed:
      sortDescriptor = NSSortDescriptor(keyPath: \PasswordItem.lastUsed, ascending: false)
    case .Favorites:
      passwordPredicate = NSPredicate(format: "isFavorite = %@", "1")
      notePredicate = NSPredicate(format: "isFavorite = %@", "1")
    case .Notes:
      showPasswords = false
      showNotes = true
    case .Passwords:
      showPasswords = true
      showNotes = false
    case .AllItems:
      showPasswords = true
      showNotes = true
    }
  }
}
