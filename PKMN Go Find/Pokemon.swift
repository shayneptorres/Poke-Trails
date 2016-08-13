//
//  Pokemon.swift
//  PKMN Go Find
//
//  Created by Shayne Torres on 7/13/16.
//  Copyright © 2016 Shayne Torres. All rights reserved./Users/ShayneTorres/Desktop/iOS/PKMN Go Find/PKMN Go Find/PokeModel.swift
//

import Foundation

class Pokemon: NSObject, NSCoding{
    var name = String()
    var number = String()
    
    override init(){}
    
    init(na: String){
        self.name = na
    }
    
    init(na: String, no: String){
        self.name = na
        switch no.characters.count {
        case 1:
            self.number = "00" + no
            break
        case 2:
            self.number = "0" + no
            break
        case 3:
            self.number = no
            break
        default:
            break
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("pokeName") as! String
        self.number = aDecoder.decodeObjectForKey("pokeNO") as! String

    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "pokeName")
        aCoder.encodeObject(number, forKey: "pokeNO")
    }
}