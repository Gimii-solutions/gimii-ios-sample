# Gimii iOS sample

A UIKit application demonstrating Didomi, the Gimii pop-in, and a Google Ad
Manager banner. For production integration and the current native API, use the
[iOS SDK guide](https://github.com/Gimii-solutions/gimii-ios/blob/main/gimii-ios/README.md).

## Dependency source

This sample pins the published `gimii-ios-sdk` package to `1.1.0-beta5` in its
Xcode project. Didomi starts at `2.30.0`; Google Mobile Ads starts at `12.0.0`,
with the project's SwiftPM version requirements determining resolution.
These pins are separate from the native SDK source checkout.

To validate unreleased native changes, use the SDK repository's own demo and
[development checks](https://github.com/Gimii-solutions/gimii-ios/blob/main/README.md).
Switching this sample to a source dependency requires intentionally replacing
the binary package selection and resolving compatible dependencies again.

## Configure and run

Use a compatible Xcode with Swift Package Manager and an iOS 13+ deployment
target, or a higher target required by your selected dependencies.

1. Open [Gimii iOS Sample.xcodeproj](Gimii%20iOS%20Sample.xcodeproj) and resolve packages.
2. Supply the configuration below, using a raiser ID from staging.
3. Run on a simulator or test device. The sample initializes Didomi, presents
   its notice when needed, and executes Gimii once the consent UI has fully
   closed. Existing consent can proceed immediately when no consent UI is visible.

| File | Configuration |
| --- | --- |
| [AppDelegate.swift](Gimii%20iOS%20Sample/AppDelegate.swift) | Didomi `API_KEY` and `NOTICE_ID` |
| [ViewController.swift](Gimii%20iOS%20Sample/ViewController.swift) | `RAISER_ID`, environment, and debug logging |
| [Info.plist](Gimii%20iOS%20Sample/Info.plist) | Your iOS `GADApplicationIdentifier` |

Keep real configuration out of commits. An ad application ID is distinct from
the banner's ad unit ID; retain a test ad unit while verifying the integration.

## Environments

| Swift value | API origin | Static origin |
| --- | --- | --- |
| `.dev` | `https://api.gimii.dev` | `https://static.gimii.dev` |
| `.staging` | `https://api.staging.gimii.fr` | `https://static.staging.gimii.fr` |
| `.production` | `https://api.gimii.fr` | `https://static.gimii.fr` |

The sample selects staging. This table describes the current SDK source; ensure
the published SDK selected by the sample contains the corresponding environment
and embedder behavior before testing another environment.

## What to verify

| Action | Check |
| --- | --- |
| Leave the notice or preferences open | Gimii stays hidden until consent is collected and the consent UI is fully dismissed |
| Answer the first Didomi notice | Gimii only displays if server configuration and capping permit it; returning from the notice does not reopen it |
| Accept full consent directly in the CMP | The initial Gimii pop-in is bypassed |
| Select a charity | Complete any follow-up CMP step, observe the thank-you screen, then verify persisted attribution |
| Load a new ad request after persistence | `gimii`, `gimii-asso`, and `gimii-cr` are attached using `Gimii.applyGimiiTargeting(to:)` |
| Enter a reminder flow when eligible | Verify minimization and touch pass-through in transparent regions |
| Open privacy preferences or refuse | Verify the expected notice/pop-in dismissal |

The sample's first banner can be built before charity selection. It does not
prove attribution for later requests; rebuild and target an ad request after
selection rather than expecting an existing request to update itself.

The sample configures Gimii and its banner once for the owning view controller.
It waits for Didomi readiness and a collected answer, handles notice/preferences
hide events, and waits for UIKit dismissal to complete before executing Gimii.
Returning to the screen does not reopen the notice or start a duplicate flow.
The Didomi listener is removed after startup or when the controller is released.
See the SDK guide for complete API and callback behavior.

## Troubleshooting

- Use `logMode: .debug` and inspect the Xcode console. A successful `execute`
  call does not guarantee an eligible display.
- Check the raiser/environment pairing, collected CMP answer, server flags, and
  display delays before changing application code.
- Check the host ad application ID if initialization fails.
- Check resolved Didomi/Google versions and host `-ObjC` settings for link errors.
- For fresh-state tests, uninstall/reinstall only this test app. Capping can
  legitimately prevent repeated display after an earlier answer.

Switch to production values and disable debug logs before distributing a host
app. The sample is an integration aid, not a complete application lifecycle or
advertising implementation.
