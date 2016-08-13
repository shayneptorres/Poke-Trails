//
//  PokePin.swift
//  PKMN Go Find
//
//  Created by Shayne Torres on 7/21/16.
//  Copyright © 2016 Shayne Torres. All rights reserved.
//

import Foundation

class PokePin {
    var lat = String()
    var lon = String()
    var id = String()
    var dropped = Bool()
    var time = String()
    
    init(){}
    
    init(la: String, lo: String, i: String, t: String){
        self.lat = la
        self.lon = lo
        self.id = i
        self.dropped = false
        self.time = t
    }
}