//
//  PokemonCollectionViewCell.swift
//  PKMN Go Find
//
//  Created by Shayne Torres on 7/13/16.
//  Copyright © 2016 Shayne Torres. All rights reserved.
//

import UIKit

class PokemonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pokeImage: UIImageView!
    
    @IBOutlet weak var pokeName: UILabel!
    
    @IBOutlet weak var pokeNO: UILabel!
    
    
    var pokemon: Pokemon?{
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        pokeName.text = pokemon!.name
        pokeNO.text = pokemon!.number
        pokeImage.image = UIImage(named: pokemon!.number)
    }

}
