import XCTest
@testable import AppleSecurity

final class AppleSecurityTests: XCTestCase {
    func testErrorTypesExist() {
        _ = AppleSecurityError.accessControlCreationFailed
    }
}
