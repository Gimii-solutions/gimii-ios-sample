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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    Didomi.shared.onReady {
      Didomi.shared.setupUI(containerController: self)
    }
    addGoogleBanner()
    
    let didomiListener = EventListener()
 
    didomiListener.onNoticeClickDisagree = { _ in
      if let window = self.view.window {
        Gimii.execute(with: window, raiserId: "ADD_RAISER_ID_HERE")
      } else {
        print("Erreur : pas de UIWindow trouvée")
      }
    }
    
    Didomi.shared.addEventListener(listener: didomiListener)

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
