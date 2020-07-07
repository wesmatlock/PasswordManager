import SwiftUI
import Combine

class PasswordGeneratorService: ObservableObject {

  struct Options {
    var lowercase = true
    var uppercase = false
    var specialCharacters = true
    var digits = false
    var length: CGFloat = 6
  }

  @Published var password: String = ""
  @Published var options = Options()

  private let uppercaseCharacters = "abcdefghijklmnopqrstuvxyz".uppercased()
  private let lowercaseCharacters = "abcdefghijklmnopqrstuvxyz"
  private let digits = "0123456789"
  private let specialCharacters = "!@#$%^&*(){}[]:?/\\|"

  var cancellable: AnyCancellable?

  init() {
    self.cancellable = generatePasswordPublisher.assign(to: \.password, on: self)
  }

  func generatePassword(with options: Options) -> String {
    var charOptions = ""

    if options.lowercase {
      charOptions += lowercaseCharacters
    }

    if options.uppercase {
      charOptions += uppercaseCharacters
    }

    if options.digits {
      charOptions += digits
    }

    if options.specialCharacters {
      charOptions += specialCharacters
    }

    var newPassword = ""

    for _ in 0...Int(options.length) {
      let char = Array(charOptions)[Int.random(in: 0..<charOptions.count)]
      newPassword.append(char)
    }

    return newPassword
  }

  var generatePasswordPublisher: AnyPublisher<String, Never> {
    $options.debounce(for: 0.3, scheduler: RunLoop.main)
      .map {[unowned self] options in
        return self.generatePassword(with: options)
      }.eraseToAnyPublisher()
  }
}
