//
//  FindPokemonViewController.swift
//  PKMN Go Find
//
//  Created by Shayne Torres on 7/13/16.
//  Copyright © 2016 Shayne Torres. All rights reserved.
//

import UIKit

class FindPokemonViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var cView: UICollectionView!
    
    @IBOutlet weak var pokeSearchBar: UISearchBar!
    
    var pokemonArr = [Pokemon]()
    var filteredPokemonArr = [Pokemon]()
    var showFilteredPoke = false
    var col = UIColor(netHex: 0xFECD06)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pokeSearchBar.delegate = self
        setSearchAppearance()
        cView.delegate = self
        cView.dataSource = self
        for (k,v) in POKEMON_LIST {
            let p = Pokemon(na: k, no: v)
            pokemonArr.append(p)
        }
        self.pokemonArr = self.pokemonArr.sort(){($0.name) > ($1.name)}
        self.pokemonArr =  self.pokemonArr.reverse()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if filteredPokemonArr.count > 0 {
            showFilteredPoke = true
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Set collection view cell appearance
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = cView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth = (view.bounds.width / 2.0) - 30.0
            let itemHeight = layout.itemSize.height
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.sectionInset.left = 8.0
            layout.sectionInset.right = 8.0
            layout.sectionInset.bottom = 4.0
            layout.invalidateLayout()
        }
    }

    // Keyboard disappears when collection view scrolls
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pokeSearchBar.resignFirstResponder()
        
    }
    
    // Search Bar Methods
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        pokeSearchBar.showsCancelButton = true
        for ob: UIView in ((searchBar.subviews[0] )).subviews {
            if let z = ob as? UIButton {
                let btn: UIButton = z
                btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        pokeSearchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        pokeSearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        pokeSearchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredPokemonArr = pokemonArr.filter({ (text) -> Bool in
            var range = NSRange()
            let tmp: NSString = text.name
            let tmp2: NSString = text.number
            let decimalCharacters = NSCharacterSet.decimalDigitCharacterSet()
            
            let decimalRange = searchText.rangeOfCharacterFromSet(decimalCharacters, options: NSStringCompareOptions(), range: nil)
            
            if decimalRange != nil {
                range = tmp2.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            } else {
                range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            }
            
            return range.location != NSNotFound
        })
        
        if(filteredPokemonArr.count == 0){
            showFilteredPoke = false;
        } else {
            showFilteredPoke = true;
        }
        self.cView.reloadData()
    }
    
    
    @IBAction func goBack(sender: UIButton) {
        switch def.valueForKey("pokeMode") as! String {
        case "find":
            performSegueWithIdentifier("backToHome", sender: self)
            break
        case "tag":
            performSegueWithIdentifier("backToTag", sender: self)
            break
        default:
            break
        }
    }
    
    func setSearchAppearance(){
        pokeSearchBar.layer.borderWidth = 1
        self.pokeSearchBar.layer.borderColor = UIColor(netHex: 0xFECD06).CGColor
        self.pokeSearchBar.layer.cornerRadius = 6.0
        self.pokeSearchBar.clipsToBounds = true
    }
    
    
    //Collection View Methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if showFilteredPoke {
            return filteredPokemonArr.count
        } else {
            return pokemonArr.count
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pokemonCell", forIndexPath: indexPath) as! PokemonCollectionViewCell
        if showFilteredPoke {
            cell.pokemon = self.filteredPokemonArr[indexPath.row]
        } else {
            cell.pokemon = self.pokemonArr[indexPath.row]
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if showFilteredPoke {
            let selectedPoke = self.filteredPokemonArr[indexPath.row]
            let pokeData = NSKeyedArchiver.archivedDataWithRootObject(selectedPoke)
            def.setObject(pokeData, forKey: "selectedPoke")
        } else {
            let selectedPoke = self.pokemonArr[indexPath.row]
            let pokeData = NSKeyedArchiver.archivedDataWithRootObject(selectedPoke)
            def.setObject(pokeData, forKey: "selectedPoke")
        }
        if def.valueForKey("pokeMode") as! String == "tag" {
            performSegueWithIdentifier("selectToFind", sender: self)
        } else {
            performSegueWithIdentifier("findPoke", sender: self)
        }
    }
    
    @IBAction func backToFind(segue: UIStoryboardSegue){}
}
