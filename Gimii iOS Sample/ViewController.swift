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
  private var bannerView: GAMBannerView!
  
  override func viewDidAppear(_ animated: Bool) {
    // Do any additional setup after loading the view.
    Didomi.shared.onReady {
      Didomi.shared.setupUI(containerController: self)
    }
    
    addGoogleBanner()
    
    // Execute Gimii
    guard let window = self.view.window else {
      print("Erreur : pas de UIWindow trouvée")
      return
    }
    
    let didomiListener = EventListener()
    
    didomiListener.onNoticeClickDisagree = { _ in
      DispatchQueue.main.async {
        Gimii.execute(with: window, raiserId: "RAISER_ID")
        Didomi.shared.removeEventListener(listener: didomiListener)
      }
    }
    
    Gimii.execute(with: window, raiserId: "RAISER_ID")
    
    Didomi.shared.addEventListener(listener: didomiListener)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func didTap(_ sender: Any) {
    tapped.toggle()
    label.text = tapped ? "Tapped" : "Not Tapped"
  }
  
  private func addGoogleBanner() {
    // Initialize the Google Mobile Ads SDK.
    GADMobileAds.sharedInstance().start()
    bannerView = GAMBannerView(adSize: GADAdSizeBanner)
    bannerView.adUnitID = "/6499/example/banner" // GAM demo unit ID
    bannerView.rootViewController = self
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bannerView)
    
    NSLayoutConstraint.activate([
      bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
    
    let request = GAMRequest()
    Gimii.applyGimiiTargeting(to: request)
    bannerView.load(request)
  }
}
