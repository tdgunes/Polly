//
//  RouterService.swift
//  Polly
//
//  Created by Taha Doğan Güneş on 18/06/15.
//  Copyright (c) 2015 Taha Doğan Güneş. All rights reserved.
//

import UIKit
import MapKit


class RouterService {
    
    var nkit = NetKit(baseURL: "http://127.0.0.1:8080")
    
    var onSuccessCallback: ((Area)->())?
    var onErrorCallback: (()->())?
    
    init(successCallback: ((Area)->())? = nil, errorCallback: (()->())? = nil) {
        self.onSuccessCallback = successCallback
        self.onErrorCallback = errorCallback
        
        if (!IS_TARGET_IPHONE_SIMULATOR){
            nkit.baseURL = "http://192.168.1.109:8080"
        }
    }
    
    func sendLocation(location:CLLocation) {
        let apiMethod = "/api/associated"
        let locationString = "POINT(\(location.coordinate.longitude) \(location.coordinate.latitude))"
        let payload = ["location": locationString, "device_id":UUID!]
        let payloadJSON = JSON(payload)
        
        nkit.post(data: payloadJSON, url: apiMethod, completionHandler: self.onSuccess, errorHandler: self.onError)
    }
    
    func onError(nkerror:NKError, nserror:NSError?) {
        println("\(nkerror): \(nserror)")
        
        if let callback = self.onErrorCallback {
            callback()
        }
    }
    
    func onSuccess(response:NKResponse) {
        println(response.string!)
    
        if let callback = self.onSuccessCallback {
            if let json = response.json {


                if let name = json["area"]["name"].asString,
                   let url = json["area"]["url"].asString,
                   let level = json["area"]["level"].asString {
                    
                   let area = Area(name: name, url: url, level: level)
                   callback(area)
                }
                       
                    
                
                
            }

        }
    }
    

}