//
//  PokeModel.swift
//  PKMN Go Find
//
//  Created by Shayne Torres on 7/14/16.
//  Copyright © 2016 Shayne Torres. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class PokeModel {
    var selectedPoke = Pokemon()
    
    func getSelectedPokemon()->Pokemon{
        if def.valueForKey("selectedPoke") != nil {
            let pokeData = def.valueForKey("selectedPoke") as! NSData
            self.selectedPoke = NSKeyedUnarchiver.unarchiveObjectWithData(pokeData) as! Pokemon
        }
        return selectedPoke
    }
    
    func allKeysForValue<K, V : Equatable>(dict: [K : V], val: V) -> [K] {
        return dict.filter{ $0.1 == val }.map{ $0.0 }
    }
    
    func getFromPokeAPI()->[PokeCoordinate]{
        let pokeNum = "001"
        var jsonParsed = [PokeCoordinate]()
        Alamofire.request(.GET, "http://fw3.firstpoststudios.com/pokemon/GetPokemon?pk=\(pokeNum)&&range=100&&lat=33.559790&lon=-117.136384").responseJSON(completionHandler: {
                response in
            let json = JSON(response.result.value!)
            var j = json[0]
            print(j["lat"])
            
            
            for i in 0..<json.count {
                let j = json[i]
                let lat = String(j["lat"])
                let lon = String(j["lon"])
                let id = String(j["id"])
                let d = String(j["dist"])
                print(lat)
                print(lon)
                print(id)
                print(d)
                let pk = PokeCoordinate(lo: lon, la: lat, i: id,  di: d)
                
                jsonParsed.append(pk)
            }
            
            print("HERE IT IS::\(jsonParsed)")
            
        })
        return jsonParsed
    }
}
