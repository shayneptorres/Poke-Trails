//
//  PokeCoordinate.swift
//  PKMN Go Find
//
//  Created by Shayne Torres on 7/14/16.
//  Copyright © 2016 Shayne Torres. All rights reserved.
//

import Foundation

class PokeCoordinate {
    var lon = String()
    var lat = String()
    var id = String()
    var dist = String()
    
    init(){}
    
    init(lo: String, la: String, i: String, di: String){
        self.lat = la
        self.lon = lo
        self.id = i
        self.dist = di
    }
}
