//
//  TagPokemonViewController.swift
//  PKMN Go Find
//
//  Created by Shayne Torres on 7/13/16.
//  Copyright © 2016 Shayne Torres. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import MapKit
import Firebase

class TagPokemonViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, GADBannerViewDelegate {
    
    var selectedPoke = Pokemon()
    let locManager = CLLocationManager()
    var initLocation = CLLocation()
    var locValue = CLLocationCoordinate2D()
    let regionRadius: CLLocationDistance = 500
    var daynight = String()
    
    @IBOutlet weak var pokeTagMap: MKMapView!
    
    @IBOutlet weak var pokeImage: UIImageView!
    
    @IBOutlet weak var tagPokeButton: UIButton!
    
    @IBOutlet weak var pokeName: MaterialLabel!
    
    @IBOutlet weak var pokeNumber: MaterialLabel!
    
    @IBOutlet weak var bannerView: GADBannerView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        pokeTagMap.delegate = self
        tagPokeButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        if def.valueForKey("selectedPoke") != nil {
            let pokeData = def.valueForKey("selectedPoke") as! NSData
            self.selectedPoke = NSKeyedUnarchiver.unarchiveObjectWithData(pokeData) as! Pokemon
        }
        pokeImage.image = UIImage(named: selectedPoke.number)
        locManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locManager.startUpdatingLocation()
            locValue = locManager.location!.coordinate
            initLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            centerMapOnLocation(initLocation)
        }
        
        let request = GADRequest()
        request.testDevices = ["f43a8cbbc140e12e0381b7e15cab5966"]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-3117377679268476/5908800495"
        bannerView.rootViewController = self
        bannerView.loadRequest(request)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if def.valueForKey("selectedPoke") != nil {
            let pokeData = def.valueForKey("selectedPoke") as! NSData
            self.selectedPoke = NSKeyedUnarchiver.unarchiveObjectWithData(pokeData) as! Pokemon
            
            pokeImage.image = UIImage(named: selectedPoke.number)
            pokeName.text = selectedPoke.name
            pokeNumber.text = selectedPoke.number
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    @IBAction func backToTag(segue: UIStoryboardSegue){}
    
    @IBAction func tagPokemon(sender: UIButton) {
        self.daynight = checkDayNight()
        let currLoc = locManager.location!.coordinate
        let currLat = Double(currLoc.latitude)
        let currLon = Double(currLoc.longitude)
        let params: [String:AnyObject] = [
            "id":"\(selectedPoke.number)",
            "lat":"\(currLat)",
            "lon":"\(currLon)",
            "d":"Day"
            
        ]
        Alamofire.request(.POST, "http://pkmn.firstpoststudios.com/pokemon/FoundPokemon?pk=\(selectedPoke.number)&lat=\(currLat)&lon=\(currLon)&d=\(self.daynight)", parameters: params, encoding: .JSON).responseJSON { error in
            print(error)
        }
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        dropPokePin(String(currLat), lo: String(currLon), i: "\(timestamp)")
    }
    
    func checkDayNight()->String{
        let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        if hour >= 5 && hour < 17 {
            return "Day"
        } else {
            return "Night"
        }
    }
    
    func removePokePin(){
        let annotations = pokeTagMap.annotations
            for _annotation in annotations {
                if let annotation = _annotation as? MKAnnotation
                {
                    self.pokeTagMap.removeAnnotation(annotation)
                }
            }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        pokeTagMap.setRegion(coordinateRegion, animated: true)
    }
    
    func dropPokePin(la: String, lo: String, i: String){
        let pokePin = MKPointAnnotation()
        pokePin.coordinate = CLLocationCoordinate2D(latitude: Double(la)!, longitude: Double(lo)!)
        pokePin.title = "\(pokeMod.allKeysForValue(POKEMON_LIST, val: i))"
        pokeTagMap.addAnnotation(pokePin)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
