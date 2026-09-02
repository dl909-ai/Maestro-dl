import Foundation
import Security
import XCTest
@testable import AppleSecurity

final class AppleSecurityTests: XCTestCase {
    func testStoreLoadUpdateAndDeleteSecret() throws {
        let identifier = UUID().uuidString
        let account = "account-\(identifier)"
        let service = "AppleSecurityTests.\(identifier)"
        let initial = Data("initial".utf8)
        let replacement = Data("replacement".utf8)

        defer {
            try? AppleSecurity.deleteSecret(account: account, service: service)
        }

        try AppleSecurity.storeSecret(initial, account: account, service: service)
        XCTAssertEqual(
            try AppleSecurity.loadSecret(account: account, service: service),
            initial
        )

        try AppleSecurity.storeSecret(replacement, account: account, service: service)
        XCTAssertEqual(
            try AppleSecurity.loadSecret(account: account, service: service),
            replacement
        )

        try AppleSecurity.deleteSecret(account: account, service: service)

        XCTAssertThrowsError(
            try AppleSecurity.loadSecret(account: account, service: service)
        ) { error in
            self.assertKeychainError(error, equals: errSecItemNotFound)
        }

        XCTAssertNoThrow(
            try AppleSecurity.deleteSecret(account: account, service: service)
        )
    }

    func testSecureEnclaveLookupUsesConstrainedQuery() throws {
        let tag = "AppleSecurityTests.secure-enclave"
        let expectedTag = Data(tag.utf8)

        let key = try AppleSecurity.copySecureEnclavePrivateKey(
            tag: tag,
            copyMatching: { query, _ in
                let attributes = query as NSDictionary
                XCTAssertEqual(
                    attributes[kSecClass as String] as? String,
                    kSecClassKey as String
                )
                XCTAssertEqual(
                    attributes[kSecAttrKeyType as String] as? String,
                    kSecAttrKeyTypeECSECPrimeRandom as String
                )
                XCTAssertEqual(
                    attributes[kSecAttrKeyClass as String] as? String,
                    kSecAttrKeyClassPrivate as String
                )
                XCTAssertEqual(
                    attributes[kSecAttrTokenID as String] as? String,
                    kSecAttrTokenIDSecureEnclave as String
                )
                XCTAssertEqual(
                    attributes[kSecAttrApplicationTag as String] as? Data,
                    expectedTag
                )
                XCTAssertEqual(
                    attributes[kSecReturnRef as String] as? Bool,
                    true
                )
                XCTAssertEqual(
                    attributes[kSecMatchLimit as String] as? String,
                    kSecMatchLimitOne as String
                )
                return errSecItemNotFound
            }
        )

        XCTAssertNil(key)
    }

    func testSecureEnclaveLookupRejectsUnexpectedResultType() {
        XCTAssertThrowsError(
            try AppleSecurity.copySecureEnclavePrivateKey(
                tag: "AppleSecurityTests.invalid-result",
                copyMatching: { _, result in
                    result?.pointee = NSString(string: "not-a-key")
                    return errSecSuccess
                }
            )
        ) { error in
            self.assertKeychainError(error, equals: errSecInternalError)
        }
    }

    func testSecureEnclaveLookupPropagatesSecurityStatus() {
        XCTAssertThrowsError(
            try AppleSecurity.copySecureEnclavePrivateKey(
                tag: "AppleSecurityTests.failure",
                copyMatching: { _, _ in errSecInteractionNotAllowed }
            )
        ) { error in
            self.assertKeychainError(error, equals: errSecInteractionNotAllowed)
        }
    }

    private func assertKeychainError(
        _ error: Error,
        equals expectedStatus: OSStatus,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case let AppleSecurityError.keychain(status) = error else {
            return XCTFail(
                "Expected AppleSecurityError.keychain, received \(error)",
                file: file,
                line: line
            )
        }
        XCTAssertEqual(status, expectedStatus, file: file, line: line)
    }
}
