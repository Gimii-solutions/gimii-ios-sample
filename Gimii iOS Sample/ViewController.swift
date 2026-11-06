//
//  ViewController.swift
//  Gimii iOS Sample
//
//  Created by Léo Giroux on 03/09/2025.
//

import UIKit
import Didomi
import GimiiSDK
import GoogleMobileAds

class ViewController: UIViewController {
  
  @IBOutlet weak var label: UILabel!
  
  private var tapped = false
  private var bannerView: AdManagerBannerView!
  private var gimii: Gimii?
  private var didomiListener: EventListener?
  private var hasConfigured = false
  private var isCmpReady = false
  private var hasExecuted = false

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Didomi dismissal makes this controller appear again. Configure only once
    // so that returning from consent UI cannot reopen it or duplicate Gimii.
    guard !hasConfigured else {
      executeAfterConsentUI()
      return
    }
    guard let window = view.window else { return }
    hasConfigured = true
    gimii = Gimii.getInstance(
      window: window,
      raiserId: "RAISER_ID",
      environment: .staging,
      logMode: .debug
    )
    addGoogleBanner()

    Didomi.shared.onReady { [weak self] in
      DispatchQueue.main.async {
        guard let self else { return }
        self.isCmpReady = true
        self.listenForConsentDismissal()
        if Didomi.shared.shouldConsentBeCollected() {
          if !Didomi.shared.isNoticeVisible() {
            Didomi.shared.setupUI(containerController: self)
          }
        } else {
          self.executeAfterConsentUI()
        }
      }
    }
  }

  private func listenForConsentDismissal() {
    guard didomiListener == nil else { return }
    let listener = EventListener()
    // Clicking agree/disagree precedes dismissal. Also handle users who answer
    // from preferences rather than using a button on the initial notice.
    listener.onHideNotice = { [weak self] _ in self?.executeAfterConsentUI() }
    listener.onHidePreferences = { [weak self] _ in self?.executeAfterConsentUI() }
    didomiListener = listener
    Didomi.shared.addEventListener(listener: listener)
  }

  private func executeAfterConsentUI() {
    DispatchQueue.main.async { [weak self] in
      guard let self, self.isCmpReady, !self.hasExecuted,
            self.viewIfLoaded?.window != nil else { return }

      // A hide event can arrive before UIKit finishes the dismissal animation.
      if let presented = self.presentedViewController {
        if presented.isBeingDismissed, let transition = presented.transitionCoordinator {
          transition.animate(alongsideTransition: nil) { [weak self] _ in
            self?.executeAfterConsentUI()
          }
        }
        return
      }
      guard !Didomi.shared.isNoticeVisible(),
            !Didomi.shared.shouldConsentBeCollected() else { return }

      self.hasExecuted = true
      self.removeDidomiListener()
      self.gimii?.execute()
    }
  }

  private func removeDidomiListener() {
    if let listener = didomiListener {
      Didomi.shared.removeEventListener(listener: listener)
      didomiListener = nil
    }
  }

  deinit {
    removeDidomiListener()
  }

  @IBAction func didTap(_ sender: Any) {
    tapped.toggle()
    label.text = tapped ? "Tapped" : "Not Tapped"
  }
  
  private func addGoogleBanner() {
    // Initialize the Google Mobile Ads SDK.
    MobileAds.shared.start()
    bannerView = AdManagerBannerView(adSize: AdSizeBanner)
    bannerView.adUnitID = "/6499/example/banner" // GAM demo unit ID
    bannerView.rootViewController = self
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bannerView)
    
    NSLayoutConstraint.activate([
      bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
    
    let request = AdManagerRequest()
    Gimii.applyGimiiTargeting(to: request)
    bannerView.load(request)
  }
}
