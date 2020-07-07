extension String {
  func getImageName() -> String {
    let urlComponents = self.lowercased().split(separator: ".")
    let count = urlComponents.count

    if urlComponents.isEmpty {
      return "placeholder"
    }
    return count > 2 ? String(urlComponents[count - 2]) : String(urlComponents.first ?? "")
  }
}
