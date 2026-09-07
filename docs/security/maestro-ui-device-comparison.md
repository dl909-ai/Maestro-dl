# Maestro UI / Device Behavior Comparison

## Purpose

This document preserves a security-focused comparison framework for GitHub-reported Maestro user-interface and device-selection behavior. It is intended for evidence correlation, regression analysis, and provenance review.

## Security classification rule

Do not collapse capability, configuration, invocation, execution, device identity, authenticated principal, or human causation.

```text
CAPABILITY
  != CONFIGURATION
  != INVOCATION
  != EXECUTION
  != DEVICE IDENTITY
  != AUTHENTICATED PRINCIPAL
  != RESPONSIBLE HUMAN / CAUSAL ACTOR
```

Likewise:

```text
SAME DEVICE MODEL != SAME DEVICE
SIMILAR UI != SAME SESSION
SIMILAR FAILURE != SHARED CAUSE
GITHUB REPORT ABOUT A DEVICE != DEVICE OWNERSHIP
SCREENSHOT / HIERARCHY != AUTHENTICATED USER IDENTITY
COMMAND REPORTED COMPLETED != EXPECTED UI EFFECT OBSERVED
REQUESTED DEVICE ID != ACTUALLY SERVICED DEVICE
```

The final transition requires independent correlation.

## GitHub-reported comparison population

| Reported device/environment | Platform | Reported behavior | Comparison use |
|---|---|---|---|
| iPhone 17 simulator / iOS 26.5 | iOS Simulator | SpringBoard/XCTAutomationSession failure after serial flows | hierarchy/session lifecycle |
| iPad (A16) simulator / iOS 26.5 | iOS Simulator | steps reportedly passed while expected visible text/taps did not occur | command-status vs UI-result |
| iPhone 17 simulator / iOS 26.5 | iOS Simulator | AX/status-bar snapshot failure terminating XCTest driver | hierarchy lifecycle |
| Multiple iOS simulators | iOS Simulator | reported device-id selection mismatch | requested-vs-serviced-device |
| iPhone simulators on ports 7001/7002/7003 | iOS Simulator | one XCTest runner reportedly fails while sibling sessions continue | per-device/session isolation |
| iOS 16.2 simulator | Maestro Cloud | modal/sheet tap reportedly uses moving/pre-wait hierarchy and misses | UI timing/gesture |
| Galaxy S21 SM-G991N | Physical Android | WebView placeholder reportedly absent from accessibility hierarchy | physical hierarchy |
| Galaxy S22 SM-S901N | Physical Android | corresponding WebView case reportedly works | comparison/control |
| HiBreak | Physical Android | WebView accessibility-name behavior reportedly fails | physical WebView |
| OnePlus 13 | Physical Android | gesture followed by wait reportedly wedges driver | gesture/runtime |
| Topwise Android POS terminal | Physical Android | driver APK reportedly rejected before UI execution | initialization negative control |
| Pixel 9 AVD | Android Emulator | hierarchy/selector/device-offline reports | emulator behavior |
| Pixel Fold AVD | Android Emulator | WebView accessibility-name failure report | WebView/UI |
| Android 17 AVD | Android Emulator | corresponding WebView case reportedly works | version control |
| Windows 11 host + physical Android | Android/host | viewer reportedly does not display connected device | viewer/presentation |

These entries are a behavioral reference population. They do **not** establish ownership of, access to, or interaction with any particular user's physical device or GitHub account.

## Normalized comparison schema

For each future report or artifact, preserve these fields where available:

- provider-native issue / pull-request / commit identifier
- device class
- physical / simulator / cloud classification
- model
- OS/runtime version
- Maestro version
- requested device identifier
- returned/observed device identifier
- session identifier
- driver/forwarding port
- hierarchy source
- command/gesture
- command status
- screenshot before/after
- visible UI effect
- XCTest / ADB / devicectl evidence
- timestamps with timezone
- authenticated principal, when provider-native evidence supports one
- provenance source and integrity identifier/hash

## Correlation sequence

```text
GITHUB ISSUE / PR
      -> REPORTED ENVIRONMENT
      -> DEVICE MODEL / SIMULATOR PROFILE
      -> OS / WEBVIEW / MAESTRO VERSION
      -> REQUESTED DEVICE IDENTIFIER
      -> ACTUAL SERVICED DEVICE (only if independently recorded)
      -> HIERARCHY BEFORE
      -> COMMAND / GESTURE
      -> HIERARCHY / SCREENSHOT AFTER
      -> OBSERVED UI EFFECT
```

A similarity finding should be assigned a confidence level and should identify the exact shared fields. Similarity alone must not be promoted to identity, execution, compromise, account attribution, or human attribution.

## Security handling

1. Prefer provider-native IDs and immutable Git object identifiers over screenshots or copied text.
2. Preserve raw source artifacts before transformation; record cryptographic hashes when files are exported.
3. Redact secrets, credentials, tokens, full hardware identifiers, personal contact data, and unnecessary device identifiers from public records.
4. Store only hashed/pseudonymous device identifiers in public correlation tables where an identifier is necessary.
5. Keep physical-device evidence separate from simulator/cloud evidence.
6. Keep GitHub-authenticated principal evidence separate from commit author/committer metadata and from responsible-human attribution.
7. Treat unavailable evidence as unresolved, not negative evidence.
8. Treat command success independently from expected UI effect and independently from successful flow completion.

## Corporate ownership context

GitHub, Inc. is part of the Microsoft corporate family. GitHub's current Terms of Service identify Microsoft as an affiliate of GitHub. GitHub itself is not separately publicly traded; Microsoft Corporation is publicly traded. Accordingly, references to public stock ownership should be made at the Microsoft level rather than treating GitHub as having an independently traded shareholder base.

Corporate ownership does not establish operational responsibility for a particular repository mutation, UI event, device session, or user action. Those require event-specific evidence.

## Evidentiary disposition

This comparison establishes a structured reference set for evaluating similarity between reported Maestro UI/device behavior and separately preserved user-experience artifacts. It does not establish that any reference device is the same device as another report, that a Maestro command actually executed on a specific physical device, that GitHub or Microsoft caused a device event, or that a particular human was responsible.
