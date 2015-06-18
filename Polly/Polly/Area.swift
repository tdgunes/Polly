//
//  Area.swift
//  Polly
//
//  Created by Taha Doğan Güneş on 18/06/15.
//  Copyright (c) 2015 Taha Doğan Güneş. All rights reserved.
//

import Foundation



class Area {
    let url:String
    let name:String
    let level:String
    var policies:[Policy] = []
    
    init(name:String,url:String,level:String) {
        self.name = name
        self.url = url
        self.level = level
    }
}