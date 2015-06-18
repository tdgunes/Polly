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
    
    let nkit = NetKit(baseURL: "http://127.0.0.1:8080/api")
    
    var onSuccessCallback: (()->())?
    var onErrorCallback: (()->())?
    
    init(successCallback: (()->())? = nil, errorCallback: (()->())? = nil) {
        self.onSuccessCallback = successCallback
        self.onErrorCallback = errorCallback
    }
    
    func sendLocation(location:CLLocation) {
        let apiMethod = "/associated"
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
            callback()
        }
    }
    

}