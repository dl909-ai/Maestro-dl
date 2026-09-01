# Apple Security Integration

This Swift package provides application-layer integrations with public Apple security APIs. It does not attempt to reimplement or bypass platform-enforced mechanisms such as KIP, PAC, PPL/SPTM/TXM, Sealed Key Protection, Memory Integrity Enforcement, or Secure Enclave isolation.

## Included controls

- Device-owner authentication through `LocalAuthentication`
- Keychain storage using `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- Secure Enclave-backed P-256 private-key generation through Security.framework
- User-presence enforcement for Secure Enclave private-key use
- Explicit Keychain delete/read helpers

## Security boundary

Apple SoC and operating-system protections remain enforced by supported Apple hardware and software. This package only requests public application-level security services.

Do not commit API keys, tokens, passwords, private keys, or other credentials to this repository. Inject service credentials at runtime from an appropriate secret-management system.

## Build

```sh
cd apple-security
swift build
swift test
```

Secure Enclave key creation requires compatible Apple hardware. Some functionality cannot be meaningfully exercised on non-Apple hosts or simulators.
