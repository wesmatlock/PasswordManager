import SwiftUI
import Combine
import LocalAuthentication
import KeychainSwift
import CryptoKit

class AuthenticationManager: ObservableObject {

  private var cancellableSet: Set<AnyCancellable> = []

  @Published var email = ""
  @Published var password = ""
  @Published var confirmedPassword = ""

  @Published var canLogin = false
  @Published var canSignup = false

  @Published var emailValidation = FormValidation()
  @Published var passwordValidation = FormValidation()
  @Published var confirmedPasswordValidation = FormValidation()
  @Published var similarityValidation = FormValidation()

  @Published var biometryType = LABiometryType.none
  @Published var biometricResult = BiometricResult.none

  @Published var isLoggedIn = false
  @Published var userAccount = User()

  @Published var resetPassword = ""
  @Published var resetPasswordValidation = FormValidation()

  private var keychain = KeychainSwift()

  private var userDefaults = UserDefaults.standard
  private var laContext = LAContext()

  struct Config {
    static let recommendedLength = 6
    static let specialCharacters = "!@#$%^&*()?/|\\:;"
    static let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    static let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8,}$")
  }

  enum BiometricResult {
    case success, failure, none
  }

  private var emailPublisher: AnyPublisher<FormValidation, Never> {
    self.$email.debounce(for: 0.2, scheduler: RunLoop.main)
      .removeDuplicates()
      .map { email in

        if email.isEmpty{
          return FormValidation(success: false, message: "")
        }


        if !Config.emailPredicate.evaluate(with: email){
          return FormValidation(success: false, message: "Invalid email address")
        }

        return FormValidation(success: true, message: "")
      }.eraseToAnyPublisher()
  }

  private var passwordPublisher: AnyPublisher<FormValidation, Never> {
    $password.debounce(for: 0.2, scheduler: RunLoop.main)
      .removeDuplicates()
      .map { password in

        if password.isEmpty{
          return FormValidation(success: false, message: "")
        }
        if password.count < Config.recommendedLength{
          return FormValidation(success: false, message: "The password length must be greater than \(Config.recommendedLength) ")
        }


        if !Config.passwordPredicate.evaluate(with: password){
          return FormValidation(success: false, message: "The password is must contain numbers, uppercase and special characters")
        }

        return FormValidation(success: true, message: "")
      }.eraseToAnyPublisher()
  }

  private var resetPasswordPublisher: AnyPublisher<FormValidation, Never> {
    $resetPassword.debounce(for: 0.2, scheduler: RunLoop.main)
      .removeDuplicates()
      .map { password in

        if password.isEmpty {
          return FormValidation(success: false, message: "")
        }
        if password.count < Config.recommendedLength {
          return FormValidation(success: false, message: "The password length must be greater than \(Config.recommendedLength)")
        }
        if !Config.passwordPredicate.evaluate(with: password) {
          return FormValidation(success: false, message: "The password must contain number, uppercase and special characters")
        }

        return FormValidation(success: true, message: "")
      }.eraseToAnyPublisher()
  }

  private var confirmPasswordPublisher: AnyPublisher<FormValidation, Never> {
    $confirmedPassword.debounce(for: 0.2, scheduler: RunLoop.main)
      .removeDuplicates()

      .map { password in

        if password.isEmpty{
          return FormValidation(success: false, message: "")
        }

        if password.count < Config.recommendedLength{
          return FormValidation(success: false, message: "The password length must be greater than \(Config.recommendedLength) ")
        }



        if !Config.passwordPredicate.evaluate(with: password){
          return FormValidation(success: false, message: "The password is must contain numbers, uppercase and special characters")
        }


        return FormValidation(success: true, message: "")
      }.eraseToAnyPublisher()
  }

  private var similarityPublisher: AnyPublisher<FormValidation, Never> {
    Publishers.CombineLatest($password, $confirmedPassword)
      .map { password, confirmedPassword in

        if password.isEmpty || confirmedPassword.isEmpty{
          return FormValidation(success: false, message: "")
        }

        if password != confirmedPassword{
          return FormValidation(success: false, message: "Passwords do not match!")
        }
        return FormValidation(success: true, message: "")
      }.eraseToAnyPublisher()
  }

  private lazy var biometricPublisher: Future<BiometricResult, Never> = {
    Future<BiometricResult, Never> {[unowned self] promise in
      let localizedReasonString = "Would like to see your biometrics :) "
      var authError: NSError?

      self.laContext.localizedCancelTitle = "Please use your PASSCODE"
      if self.canAuthenticate(error: &authError) {
        self.laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                      localizedReason: localizedReasonString) { success, evaluateError in
          return promise(.success(BiometricResult.success))
        }
      }
      else {
        return promise(.success(BiometricResult.failure))
      }
    }
  }()

  init() {
    emailPublisher
      .assign(to: \.emailValidation, on: self)
      .store(in: &cancellableSet)

    passwordPublisher
      .assign(to: \.passwordValidation, on: self)
      .store(in: &cancellableSet)

    resetPasswordPublisher
      .assign(to: \.resetPasswordValidation, on: self)
      .store(in: &cancellableSet)

    confirmPasswordPublisher
      .assign(to: \.confirmedPasswordValidation, on: self)
      .store(in: &cancellableSet)

    similarityPublisher
      .assign(to: \.similarityValidation, on: self)
      .store(in: &cancellableSet)

    // Login
    Publishers.CombineLatest(emailPublisher, passwordPublisher)
      .map { emailValidation, passwordValidation  in
        emailValidation.success && passwordValidation.success
      }.assign(to: \.canLogin, on: self)
      .store(in: &cancellableSet)

    // Sign Up
    Publishers.CombineLatest4(emailPublisher, passwordPublisher, confirmPasswordPublisher, similarityPublisher)
      .map { emailValidation, passwordValidation, confirmedPasswordValidation, similarityValidation  in
        emailValidation.success && passwordValidation.success && confirmedPasswordValidation.success && similarityValidation.success
      }.assign(to: \.canSignup, on: self)
      .store(in: &cancellableSet)

  }

  func loginWithBiometric()  {

    biometricPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        switch result {
        case .success:
          self?.isLoggedIn = true
        case .failure:
          self?.isLoggedIn = false
          print("ERROR authenticating with biometric")
        case .none:
           break
        }
      }
      .store(in: &cancellableSet)
  }

  func authenticateWithBiometric() {
    guard hasAccount() else { return }

    biometricPublisher
      .receive(on: DispatchQueue.main)
      .assign(to: \.biometricResult, on: self)
      .store(in: &cancellableSet)
  }

  func hasAccount() -> Bool {
    keychain.get(AuthKeys.email) != nil
  }

  func createAccount() -> Bool {

    guard !hasAccount() else { return false }

    let hashedPassword = hashPassword(password)
    let emailResult = keychain.set(email.lowercased(), forKey: AuthKeys.email,
                                   withAccess: .accessibleWhenPasscodeSetThisDeviceOnly)
    let passwordResult = keychain.set(hashedPassword, forKey: AuthKeys.password,
                                      withAccess: .accessibleWhenPasscodeSetThisDeviceOnly)

    if emailResult && passwordResult {
      login()
      return true
    }

    return false
  }

  func login() {
    userDefaults.set(true, forKey: AuthKeys.isLoggedIn)
    self.isLoggedIn = true
  }

  func logout() {
    userDefaults.set(false, forKey: AuthKeys.isLoggedIn)
    self.isLoggedIn = false
  }

  func canAuthenticate(error: NSErrorPointer) -> Bool {
    self.laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: error)
  }

  func authenticate() -> Bool {
    if !hasAccount() { return false }

    if let savedEmail = keychain.get(AuthKeys.email), let savedPassword = keychain.get(AuthKeys.password) {

      let hashedPassword = hashPassword(password)
      if savedEmail == email.lowercased() && hashedPassword == savedPassword {
        login()
        return true
      }
    }
    return false
  }

  func deleteAccount() {
    keychain.delete(AuthKeys.email)
    keychain.delete(AuthKeys.password)
    keychain.delete(AuthKeys.salt)
  }

  private func hashPassword(_ password: String, reset: Bool = false) -> String {
    var salt = ""

    if let savedSalt = keychain.get(AuthKeys.salt), !reset {
      salt = savedSalt
    }
    else {
      let key = SymmetricKey(size: .bits256)
      salt = key.withUnsafeBytes({ Data(Array($0)).base64EncodedString() })
      keychain.set(salt, forKey: AuthKeys.salt)
    }

    guard let data = "\(password)\(salt)".data(using: .utf8) else { return "" }
    let digest = SHA256.hash(data: data)
    return digest.map{String(format: "%02hhx", $0)}.joined()
  }

  func saveResetPassword() -> Bool {
    let hashedPassword = hashPassword(resetPassword, reset: true)
    let passwordResult = keychain.set(hashedPassword,
                                      forKey: AuthKeys.password,
                                      withAccess: .accessibleWhenPasscodeSetThisDeviceOnly)

    return passwordResult
  }

  func getBiometeryType() {
    var authError: NSError?
    if canAuthenticate(error: &authError) {
      biometryType = laContext.biometryType
    }
  }
}
