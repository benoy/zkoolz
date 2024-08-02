//
//  ZKBaseViewController.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 14/06/24.
//

import UIKit
import GoogleMobileAds

class ZKBaseViewController: UIViewController {
    
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd?
    
    private var bgImageView: UIImageView = UIImageView(image: UIImage(named: "ScreenBg"))
    
    var callback: () -> Void = { }
    
    class var instance: Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T(nibName: String(describing: T.self), bundle: Bundle(for: T.self))
        }
        return instantiateFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        bgImageView.frame = UIScreen.main.bounds
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgImageView)
        bgImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        bgImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        bgImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.view.backgroundColor = UIColor(argb: 0xFFFFE4FF)
        
        
        addAdBanner()
        loadInterstitial()
        view.sendSubviewToBack(bgImageView)
    }
    
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapBack(button: UIButton) {
        popViewController()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
         willShowKeyboard(notification: notification)
    }

    @objc func keyboardWillHide(notification: NSNotification){
        willHideKeyboard(notification: notification)
    }

    func showOkAlert(message: String, titile: String = "Error") {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: titile, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
            self.present(alert, animated: true)
        }
        
    }
    
    func showYesNoAlert(message: String, titile: String = "", callback: @escaping (Bool) -> Void ) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: titile, message: message, preferredStyle: UIAlertController.Style.alert)
            
            let noAction = UIAlertAction(title: "No", style: .destructive, handler: { action in
                callback(false)
            })
            
            let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                callback(true)
            })
            
            
            alert.addAction(noAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true)
        }
        
    }
    
    func willShowKeyboard(notification: NSNotification) {
        
        if let uInfo = notification.userInfo {
            
            let frm = uInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            let ht = frm?.cgRectValue.height ?? 0.0
            let duration = (uInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.1
           showKeyboard(with: ht, animationDuration: duration)
        }
    }
    
    func willHideKeyboard(notification: NSNotification) {
        if let uInfo = notification.userInfo {
            let duration = (uInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.1
            hideKeyboard(with: 8, animationDuration: duration)
        }
    }
    
    func showKeyboard(with height: Double, animationDuration: Double) {
        
    }
    
    func hideKeyboard(with height: Double, animationDuration: Double) {
        
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
    }
    
    
}

extension ZKBaseViewController: GADFullScreenContentDelegate {

    func addAdBanner() {
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = admobBannerUnitId
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)

        // Add constraints to position the banner at the bottom of the screen
        view.addConstraints([
           NSLayoutConstraint(item: bannerView!, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0),
           NSLayoutConstraint(item: bannerView!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        ])
    }

    func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: admobInterstitialUinitId, request: request) { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
            self.callback()
        }
    }

    func showInterstitial(callback: @escaping () -> Void ) {
        self.callback = callback
        if let interstitial = interstitial {
            DispatchQueue.main.async {
                interstitial.present(fromRootViewController: ZKAppController.shared.window.rootViewController)
            }
        } else {
            print("Ad wasn't ready")
        }
    }

    // GADFullScreenContentDelegate methods
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        callback()
    }

    func adWillPresentFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }

    func adDidRecordImpression(_ ad: any GADFullScreenPresentingAd) {

    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        // Load a new interstitial ad for the next time
        loadInterstitial()
    }
}
