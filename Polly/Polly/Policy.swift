//
//  Policy.swift
//  Polly
//
//  Created by Taha Doğan Güneş on 18/06/15.
//  Copyright (c) 2015 Taha Doğan Güneş. All rights reserved.
//

import UIKit

class Policy {
    var text:String = ""
    var color:UIColor = UIColor.blackColor()
    
    init(policyJSON:JSON){
        if let jsonText = policyJSON["text"].asString,
           let jsonColor = policyJSON["color"].asString {
           self.text = jsonText
           self.color = UIColor(rgba: jsonColor)
        }
    }
    
}