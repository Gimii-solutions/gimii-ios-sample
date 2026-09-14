# Gimii iOS SDK

## Run this sample

1. Open `Gimii iOS Sample.xcodeproj` in Xcode and let Swift Package Manager resolve the packages.
2. Replace the placeholders:

| File | Value |
|---|---|
| `Gimii iOS Sample/AppDelegate.swift` | Didomi `API_KEY` and `NOTICE_ID` |
| `Gimii iOS Sample/ViewController.swift` | `RAISER_ID` (the sample uses the staging environment) |
| `Gimii iOS Sample/Info.plist` | Your `GADApplicationIdentifier` (`ID HERE`) |

3. Run the app and tap "Disagree" on the Didomi notice: the Gimii pop-in appears.

## Integrate Gimii SDK in Your iOS App

This guide explains how to add the Gimii iOS SDK to your application, configure environments, enable logging, and optionally apply ad targeting to Google Ad Manager/AdMob requests.

### 1) Add the Dependency

Add the Gimii iOS SDK via Swift Package Manager (SPM). In Xcode:

1. Go to `File > Add Packages`.
2. Enter the package URL: `https://github.com/Gimii-solutions/gimii-ios-sdk`.
3. Select version `1.1.0-beta4` or later.
4. Add the package to your project.

The SDK does not bring its dependencies: add these packages to your app too.

| Package | URL | Version |
|---|---|---|
| Didomi | `https://github.com/didomi/didomi-ios-sdk-spm` | 2.30.0 or later, below 3.0.0 |
| Google Mobile Ads | `https://github.com/googleads/swift-package-manager-google-mobile-ads` | 12.x or 13.x |

The SDK requires iOS 13 or later.

### 2) Configure Didomi IDs

In your app’s `AppDelegate`, add the Didomi API key and notice ID:

```swift
let parameters = DidomiInitializeParameters(apiKey: "API_KEY", noticeID: "NOTICE_ID")
Didomi.shared.initialize(parameters)      
```

### 3) Add Google Ads Application ID

Add your application ID to `Info.plist`. This key is required: without it, Google Mobile Ads crashes the app at launch.

```xml
<key>GADApplicationIdentifier</key>
<string>###########</string>
```

### 4) Initialize and Start Gimii

Initialize the Gimii SDK in a `UIViewController` (e.g., your main ViewController) after Didomi is ready. Below is an example implementation:

```swift
import UIKit
import Didomi
import GimiiSDK
import GoogleMobileAds

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Didomi.shared.onReady {
            Didomi.shared.setupUI(containerController: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let didomiListener = EventListener()
        
        if let window = self.view.window {
            let gimii = Gimii.getInstance(
                window: window,
                raiserId: "RAISER_ID",
                environment: .production, // .qa | .staging | .production
                logMode: .info // .debug for verbose logs, .info for standard
            )
            
            didomiListener.onNoticeClickDisagree = { _ in
                DispatchQueue.main.async {
                    gimii.execute()
                    Didomi.shared.removeEventListener(listener: didomiListener)
                }
            }
            gimii.execute()
        }
        
        Didomi.shared.addEventListener(listener: didomiListener)
    }
}
```

Gimii is executed when the user refuses the CMP (Consent Management Platform).

Gimii Events :

```swift
...
gimii.setEventListener(self)
...
extension ViewController: GimiiEventListener {
  
  func onRefused() {
    Logger.debug("GimiiEventListener onRefused")
  }
  
  func onAccepted() {
    Logger.debug("GimiiEventListener onAccepted")
  }
  
  func onDisplayed() {
    Logger.debug("GimiiEventListener onDisplayed")
  }
  
  func onError(_ error: GimiiError) {
    Logger.debug("GimiiEventListener onError - \(error)")
  }
}
```

`onError` is only called for network, configuration, consent and interaction errors. A display delay that has not elapsed yet is not reported.


### 5) Environments

Available environments:
- `.qa` → `https://qa.api.gimii.dev` / `https://static.gimii.dev/gimii-embedder.html`
- `.staging` → `https://api.gimii.dev` / `https://static.gimii.dev/gimii-embedder.html`
- `.production` → `https://api.gimii.fr` / `https://static.gimii.fr/gimii-embedder.html`

Select the environment when calling `Gimii.getInstance(...)`.

### 6) Logging

`LogMode` options:
- `.debug` → prints DEBUG, INFO, ERROR, CRITICAL
- `.info` → prints INFO, ERROR, CRITICAL
- `nil` → disables all logs

Set it via `Gimii.getInstance(logMode: .debug)` during initialization.

### 7) Ad Targeting (Optional)

If you use Google Ad Manager/AdMob, you can apply Gimii custom targeting to an `AdManagerRequest`:

```swift
import GoogleMobileAds

let request = AdManagerRequest()
Gimii.applyGimiiTargeting(to: request)
```

When an association is selected, the SDK adds the following custom targeting:
- `gimii` → your `raiserId`
- `gimii-asso` → selected association ID
- `gimii-cr` → composite key `${raiserId}-${associationId}`

If no association is available, no tags are applied.


### 8) Troubleshooting

- Set `logMode: .debug` to get detailed logs in the console with tag `Gimii`.
- Verify `raiserId` is correct.
- Ensure Didomi is initialized and consent is accessible.
- Confirm network access and environment selection.

---

That's it! Gimii will handle the display and logic.

## License

© 2025 Gimii. All rights reserved.
