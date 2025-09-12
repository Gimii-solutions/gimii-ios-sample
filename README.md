# Gimii iOS SDK

## Integrate Gimii SDK in Your iOS App

This guide explains how to add the Gimii iOS SDK to your application, configure environments, enable logging, and optionally apply ad targeting to Google Ad Manager/AdMob requests.

### 1) Add the Dependency

Add the Gimii iOS SDK via Swift Package Manager (SPM). In Xcode:

1. Go to `File > Add Packages`.
2. Enter the package URL: `https://github.com/Gimii-solutions/gimii-ios-sdk`.
3. Select the latest release (e.g., `1.1.0-beta1`).
4. Add the package to your project.

The Gimii iOS SDK depends on:
- Didomi SDK
- Google Mobile Ads (for ad targeting)

### 2) Configure Didomi IDs

In your app’s `AppDelegate`, add the Didomi API key and notice ID:

```swift
let parameters = DidomiInitializeParameters(apiKey: "API_KEY", noticeID: "NOTICE_ID")
Didomi.shared.initialize(parameters)      
```

### 3) Add Google Ads Application ID

If using Google Ads, add your application ID to `Info.plist`:

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
                raiserId: "raiser_eac3e0ae",
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

### 5) Environments

Available environments:
- `.qa` → `https://qa.api.gimii.dev` / `https://qa.static.gimii.dev/app-mobile.html`
- `.staging` → `https://api.gimii.dev` / `https://static.gimii.dev/app-mobile.html`
- `.production` → `https://api.gimii.fr` / `https://static.gimii.fr/app-mobile.html`

Select the environment when calling `Gimii.getInstance(...)`.

### 6) Logging

`LogMode` options:
- `.debug` → prints DEBUG, INFO, ERROR, CRITICAL
- `.info` → prints INFO, ERROR, CRITICAL
- `nil` → disables all logs

Set it via `Gimii.getInstance(logMode: .debug)` during initialization.

### 7) Ad Targeting (Optional)

If you use Google Ad Manager/AdMob, you can apply Gimii custom targeting to a `GAMRequest`:

```swift
import GoogleMobileAds

let request = GAMRequest()
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
