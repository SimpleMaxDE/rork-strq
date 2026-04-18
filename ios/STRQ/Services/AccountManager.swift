import Foundation
import AuthenticationServices
import Observation

nonisolated struct STRQAccount: Codable, Sendable, Equatable {
    var userId: String
    var displayName: String?
    var email: String?
    var signedInAt: Date
}

@Observable
@MainActor
final class AccountManager: NSObject {
    static let shared = AccountManager()

    private let accountKey = "strq_account_v1"

    private(set) var account: STRQAccount?
    var isCheckingCredential: Bool = false

    var isSignedIn: Bool { account != nil }
    var displayName: String? { account?.displayName }

    override init() {
        super.init()
        if let data = UserDefaults.standard.data(forKey: accountKey),
           let decoded = try? JSONDecoder().decode(STRQAccount.self, from: data) {
            self.account = decoded
        }
    }

    func configureRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func handleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else {
                ErrorReporter.shared.breadcrumb("Apple sign-in: unexpected credential", category: "account")
                return
            }
            let userId = credential.user
            var name: String? = account?.displayName
            if let full = credential.fullName {
                let formatter = PersonNameComponentsFormatter()
                formatter.style = .default
                let built = formatter.string(from: full).trimmingCharacters(in: .whitespaces)
                if !built.isEmpty { name = built }
            }
            let email = credential.email ?? account?.email
            let record = STRQAccount(
                userId: userId,
                displayName: name,
                email: email,
                signedInAt: Date()
            )
            self.account = record
            persist()
            Analytics.shared.identify(userId: userId, traits: [:])
            Analytics.shared.track(.account_signed_in)
            ErrorReporter.shared.breadcrumb("Signed in with Apple", category: "account")
        case .failure(let error):
            let nsError = error as NSError
            if nsError.code == ASAuthorizationError.canceled.rawValue {
                return
            }
            ErrorReporter.shared.breadcrumb("Apple sign-in failed: \(error.localizedDescription)", category: "account")
            Analytics.shared.track(.account_sign_in_failed)
        }
    }

    func signOut() {
        account = nil
        UserDefaults.standard.removeObject(forKey: accountKey)
        Analytics.shared.identify(userId: nil, traits: [:])
        Analytics.shared.track(.account_signed_out)
        ErrorReporter.shared.breadcrumb("Signed out", category: "account")
    }

    func refreshCredentialState() {
        guard let userId = account?.userId else { return }
        isCheckingCredential = true
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userId) { [weak self] state, _ in
            Task { @MainActor in
                guard let self else { return }
                self.isCheckingCredential = false
                switch state {
                case .revoked, .notFound:
                    self.signOut()
                default:
                    break
                }
            }
        }
    }

    private func persist() {
        guard let account,
              let data = try? JSONEncoder().encode(account) else { return }
        UserDefaults.standard.set(data, forKey: accountKey)
    }
}
