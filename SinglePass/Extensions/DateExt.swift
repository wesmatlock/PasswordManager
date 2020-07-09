import Foundation

extension Date {
  func format(_ format: String = "E, d MMM yyyy HH:MM") -> String {

    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.locale = Locale.autoupdatingCurrent

    let component = formatter.string(from: self)
    return component
  }
}
