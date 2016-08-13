//
//  TagMapViewController.swift
//  PKMN Go Find
//
//  Created by Shayne Torres on 7/14/16.
//  Copyright © 2016 Shayne Torres. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON
import Firebase
import GoogleMobileAds


class FindMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, GADBannerViewDelegate {
    var pokemonArr = [Pokemon]()
    let locManager = CLLocationManager()
    var initLocation = CLLocation()
    var locValue = CLLocationCoordinate2D()
    let regionRadius: CLLocationDistance = 500
    private var mapChangedFromUserInteraction = false
    var pokemon = Pokemon()
    var pokeCoord = [PokeCoordinate]()
    var pokeIndex = Int()
    var pulledPokePins = [PokePin]()
    var droppedPokePins = [PokePin]()
    var lat = String()
    var lon = String()
    var prevCenter = CLLocation()
    var buttonArray = [MaterialButton]()
    var currentFilter = "All"
    
    
    
    @IBOutlet weak var pokeLabel: MaterialView!
    
    @IBOutlet weak var pokeMap: MKMapView!
    
    @IBOutlet weak var pokeImage: UIImageView!
    
    @IBOutlet weak var pokeName: MaterialLabel!
    
    @IBOutlet weak var pokeNumber: MaterialLabel!
    
    @IBOutlet weak var pokeUserLocateButton: UIButton!
    
    @IBOutlet weak var pokeSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var leftArrowButton: UIButton!
    
    @IBOutlet weak var rightArrowButton: UIButton!
    
    @IBOutlet weak var allButton: MaterialButton!
    
    @IBOutlet weak var dayButton: MaterialButton!
    
    @IBOutlet weak var nightButton: MaterialButton!
    
    @IBOutlet var bannerView: GADBannerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonArray = [allButton, dayButton, nightButton]
        droppedPokePins = []
        pokeMap.delegate = self
        pokeUserLocateButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        leftArrowButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        rightArrowButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        setPokeInfo()
        getAndAlphabetizePoke()
        getCurrentPokemonIndex()
        pokeSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        pokeSpinner.color = UIColor.redColor()
        locManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locManager.startUpdatingLocation()
            locValue = locManager.location!.coordinate
            initLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            centerMapOnLocation(initLocation)
        }
        getFromPokeAPI(pokemon.number, f: currentFilter)
        
        let request = GADRequest()
        request.testDevices = ["f43a8cbbc140e12e0381b7e15cab5966"]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-3117377679268476/9001867692"
        bannerView.rootViewController = self
        bannerView.loadRequest(request)
        
        // Set Gesture Recgonizers
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(FindMapViewController.handleSwipes(_:)))
        leftSwipe.direction = .Left
        self.pokeLabel.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(FindMapViewController.handleSwipes(_:)))
        rightSwipe.direction = .Right
        self.pokeLabel.addGestureRecognizer(rightSwipe)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setSelectedButton(allButton)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func mapViewRegionDidChange() -> Bool {
        let view = self.pokeMap.subviews[0]
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    
    @IBAction func rightArrowtapped(sender: UIButton) {
        queueNextPoke()
    }
    
    @IBAction func leftArrowTapped(sender: UIButton) {
        queuePrevPoke()
    }
    
    // Swipe Handler Functions
    func handleSwipes(sender: UISwipeGestureRecognizer){
        if sender.direction == .Left {
            queueNextPoke()
        } else if sender.direction == .Right {
            queuePrevPoke()
        }
    }
    
    func queueNextPoke(){
        if pokeIndex < 150 {
            setNewPokeInfo(pokemonArr[pokeIndex + 1])
            pokeIndex += 1
            resetPokeView()
        }
    }
    
    func queuePrevPoke(){
        if pokeIndex > 0 {
            setNewPokeInfo(pokemonArr[pokeIndex - 1])
            pokeIndex -= 1
            resetPokeView()
        }
    }
    
    func resetPokeView(){
        removePokePins()
        getFromPokeAPI(pokemonArr[pokeIndex].number, f: currentFilter)
        self.droppedPokePins.removeAll()
    }
    
    func getAndAlphabetizePoke(){
        for (k,v) in POKEMON_LIST {
            let p = Pokemon(na: k, no: v)
            pokemonArr.append(p)
        }
        self.pokemonArr = self.pokemonArr.sort(){($0.name) > ($1.name)}
        self.pokemonArr =  self.pokemonArr.reverse()
    }
    
    func getCurrentPokemonIndex(){
        for i in pokemonArr {
            if i.name == pokemon.name {
                pokeIndex = pokemonArr.indexOf(i)!
            }
        }
    }
    
    func removePokePins(){
        let allAnnotations = self.pokeMap.annotations
        self.pokeMap.removeAnnotations(allAnnotations)
    }
    
    
    // Button functions
    
    func setSelectedButton(btn: MaterialButton){
        btn.chosen = true
        btn.enabled = false
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = UIColor(netHex: 0xBB9601).CGColor
        btn.layer.backgroundColor = UIColor(netHex: 0xFECD06).CGColor
    }
    
    func resetButton(btn: MaterialButton){
        btn.chosen = false
        btn.enabled = true
        btn.layer.borderWidth = 0.0
        btn.layer.borderColor = UIColor(netHex: 0xBB9601).CGColor
        btn.layer.backgroundColor = UIColor(netHex: 0xBB9601).CGColor
        droppedPokePins.removeAll()
    }
    
    func resetUnselectedButtons(){
        for i in buttonArray {
            resetButton(i)
        }
    }
    
    @IBAction func selectAllPoke(sender: MaterialButton) {
        removePokePins()
        if !sender.chosen {
            resetUnselectedButtons()
            setSelectedButton(sender)
            getFromPokeAPI(pokemonArr[pokeIndex].number, f:currentFilter)
        } else {
            
        }
        
    }
    
    @IBAction func selectDayPoke(sender: MaterialButton) {
        removePokePins()
        if !sender.chosen {
            resetUnselectedButtons()
            setSelectedButton(sender)
            currentFilter = "Day"
            getFromPokeAPI(pokemonArr[pokeIndex].number, f:currentFilter)
        } else {
            
        }
        
    }
    
    @IBAction func selectNightPoke(sender: MaterialButton) {
        removePokePins()
        if !sender.chosen {
            resetUnselectedButtons()
            setSelectedButton(sender)
            currentFilter = "Night"
            getFromPokeAPI(pokemonArr[pokeIndex].number, f:currentFilter)
        } else {
            
        }
        
    }
    
    
    
    
    // Map View Functions
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        getFromPokeAPI(pokemonArr[pokeIndex].number, f:currentFilter)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        return pinView
    }
    
    func setPokeInfo(){
        pokemon = pokeMod.getSelectedPokemon()
        pokeImage.image = UIImage(named: pokemon.number)
        pokeName.text = pokemon.name
        pokeNumber.text = pokemon.number
    }
    
    func setNewPokeInfo(p: Pokemon){
        pokeImage.image = UIImage(named: p.number)
        pokeName.text = p.name
        pokeNumber.text = p.number
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locValue = manager.location!.coordinate
        initLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        pokeMap.setRegion(coordinateRegion, animated: true)
    }
    
    func dropPokePin(la: String, lo: String, i: String, t: String){
        let pokePin = MKPointAnnotation()
        pokePin.coordinate = CLLocationCoordinate2D(latitude: Double(la)!, longitude: Double(lo)!)
        pokePin.title = "\(pokemonArr[pokeIndex].name)"
        pokePin.subtitle = "Found: \(t) Time"
        pokeMap.addAnnotation(pokePin)
        
    }
    
    @IBAction func locatePokeUser(sender: UIButton) {
        locValue = locManager.location!.coordinate
        initLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        centerMapOnLocation(initLocation)
    }
    
    func findMapRegionDistance()->CLLocationDistance{
        let span = pokeMap.region.span
        let center = pokeMap.region.center
        //        May use later
        //        let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        //        let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc3 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
        let loc4 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)
        
        let metersInLatitude = loc3.distanceFromLocation(loc4)
        let kmetersInLatitude = metersInLatitude/1000
        return kmetersInLatitude
    }
    
    func getFromPokeAPI(n: String, f: String){
        pokeSpinner.hidden = false
        pokeSpinner.startAnimating()
        Alamofire.request(.GET, "http://pkmn.firstpoststudios.com/pokemon/GetPokemon?pk=\(n)&&range=\(findMapRegionDistance())&&lat=\(pokeMap.centerCoordinate.latitude)&lon=\(pokeMap.centerCoordinate.longitude)").responseJSON(completionHandler: {
            response in
            let json = JSON(response.result.value!)
            print(json)
            var copyCount = 0
            if json["id"] != nil {
                // If there is only one pokemon listed
                let lat = String(json["lat"])
                let lon = String(json["lon"])
                let id = String(json["id"])
                let time = String(json["daynight"])
                let poPin = PokePin(la: lat, lo: lon, i: id, t: time)
                for k in self.droppedPokePins {
                    if poPin.lat == k.lat && poPin.lon == k.lon {
                        copyCount += 1
                    }
                }
                if copyCount == 0 {
                    self.pulledPokePins.append(poPin)
                }
            } else {
                // If there is more than one pokemon listed
                let count = json.count
                for i in 0..<count {
                    print("p")
                    let j = json[i]
                    let lat = String(j["lat"])
                    let lon = String(j["lon"])
                    let id = String(j["id"])
                    let t = String(j["daynight"])
    
                    let poPin = PokePin(la: lat, lo: lon, i: id, t: t)
                    for k in self.droppedPokePins {
                        if poPin.lat == k.lat && poPin.lon == k.lon {
                            copyCount += 1
                        }
                    }
                    if copyCount == 0 {
                        self.pulledPokePins.append(poPin)
                    }
                }
            }
            
            
            for i in self.pulledPokePins {
                print(f)
                if i.dropped == false {
                    if f != "All" {
                        if i.time == f {
                            self.dropPokePin(i.lat, lo: i.lon, i: i.id, t: i.time)
                            self.droppedPokePins.append(i)
                            i.dropped = true
                        }
                    } else {
                        self.dropPokePin(i.lat, lo: i.lon, i: i.id, t: i.time)
                        self.droppedPokePins.append(i)
                        i.dropped = true
                    }
                }
            }
            self.pulledPokePins.removeAll()
            self.pokeSpinner.stopAnimating()
            self.pokeSpinner.hidden = true
        })
    }
}

extension MKMapView {
    func edgePoints() -> [CLLocationCoordinate2D] {
        var edges = [CLLocationCoordinate2D]()
        let nePoint = CGPoint(x: self.bounds.maxX, y: self.bounds.origin.y)
        let swPoint = CGPoint(x: self.bounds.minX, y: self.bounds.maxY)
        let neCoord = self.convertPoint(nePoint, toCoordinateFromView: self)
        let swCoord = self.convertPoint(swPoint, toCoordinateFromView: self)
        edges.append(neCoord)
        edges.append(swCoord)
        return edges
    }
    
    func centerPoint()-> [CLLocationCoordinate2D]{
        var center = [CLLocationCoordinate2D]()
        let cPoint = CGPoint(x: self.bounds.maxX/2, y: self.bounds.origin.y/2)
        let cCoord = self.convertPoint(cPoint, toCoordinateFromView: self)
        center.append(cCoord)
        return center
    }
}

