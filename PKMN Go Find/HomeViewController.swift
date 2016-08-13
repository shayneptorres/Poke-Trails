//
//  HomeViewController.swift
//  PKMN Go Find
//
//  Created by Shayne Torres on 7/13/16.
//  Copyright © 2016 Shayne Torres. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import GoogleMobileAds

class HomeViewController: UIViewController, GADBannerViewDelegate {
    
    let locManager = CLLocationManager()
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.requestWhenInUseAuthorization()
        print("Google Mobile Ads SDK version: " + GADRequest.sdkVersion())
        let request = GADRequest()
        request.testDevices = ["f43a8cbbc140e12e0381b7e15cab5966"]
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-3117377679268476/4351342092"
        bannerView.rootViewController = self
        bannerView.loadRequest(request)
    }
    
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        bannerView.hidden = false
    }
    
    func adView(bannerView: GADBannerView!,
                didFailToReceiveAdWithError error: GADRequestError!) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("This did happen")
        print("THE PHONE VIEW SIZE: \(view.bounds.width)")
    }
    
    @IBAction func backToHome(segue: UIStoryboardSegue){}
    
    
    
    
    @IBAction func findPoke(sender: UIButton) {
        def.setValue("find", forKey: "pokeMode")
    }
    
    @IBAction func tagPoke(sender: UIButton) {
        def.setValue("tag", forKey: "pokeMode")
    }
    
    
}
