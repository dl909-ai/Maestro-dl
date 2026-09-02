import Foundation
import LocalAuthentication
import Security

public enum AppleSecurityError: Error {
    case authenticationUnavailable(Error?)
    case authenticationFailed(Error)
    case keychain(OSStatus)
    case accessControlCreationFailed
    case secureEnclaveKeyCreationFailed(Error?)
}

public enum AppleSecurity {
    typealias SecItemCopyMatchingImplementation = (
        CFDictionary,
        UnsafeMutablePointer<CFTypeRef?>?
    ) -> OSStatus

    public static func requireOwnerAuthentication(
        reason: String = "Authenticate to access protected data"
    ) async throws {
        let context = LAContext()
        var evaluationError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &evaluationError) else {
            throw AppleSecurityError.authenticationUnavailable(evaluationError)
        }

        do {
            try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
        } catch {
            throw AppleSecurityError.authenticationFailed(error)
        }
    }

    public static func storeSecret(
        _ data: Data,
        account: String,
        service: String
    ) throws {
        let lookup: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]

        let update: [String: Any] = [
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData as String: data
        ]

        let updateStatus = SecItemUpdate(
            lookup as CFDictionary,
            update as CFDictionary
        )

        if updateStatus == errSecSuccess {
            return
        }

        guard updateStatus == errSecItemNotFound else {
            throw AppleSecurityError.keychain(updateStatus)
        }

        var insert = lookup
        insert[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        insert[kSecValueData as String] = data

        let addStatus = SecItemAdd(insert as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw AppleSecurityError.keychain(addStatus)
        }
    }

    public static func loadSecret(
        account: String,
        service: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else {
            throw AppleSecurityError.keychain(status)
        }
        guard let data = result as? Data else {
            throw AppleSecurityError.keychain(errSecInternalError)
        }
        return data
    }

    public static func deleteSecret(account: String, service: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AppleSecurityError.keychain(status)
        }
    }

    public static func createSecureEnclavePrivateKey(tag: String) throws -> SecKey {
        var accessError: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage, .userPresence],
            &accessError
        ) else {
            throw AppleSecurityError.accessControlCreationFailed
        }

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: Data(tag.utf8),
                kSecAttrAccessControl as String: accessControl
            ]
        ]

        var keyError: Unmanaged<CFError>?
        guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &keyError) else {
            throw AppleSecurityError.secureEnclaveKeyCreationFailed(keyError?.takeRetainedValue())
        }
        return key
    }

    public static func copySecureEnclavePrivateKey(tag: String) throws -> SecKey? {
        try copySecureEnclavePrivateKey(
            tag: tag,
            copyMatching: SecItemCopyMatching
        )
    }

    static func copySecureEnclavePrivateKey(
        tag: String,
        copyMatching: SecItemCopyMatchingImplementation
    ) throws -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecAttrApplicationTag as String: Data(tag.utf8),
            kSecReturnRef as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = copyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw AppleSecurityError.keychain(status)
        }
        guard let key = result as? SecKey else {
            throw AppleSecurityError.keychain(errSecInternalError)
        }
        return key
    }
}
