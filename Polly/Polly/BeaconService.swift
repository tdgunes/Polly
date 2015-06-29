//
//  BeaconService.swift
//  Polly
//
//  Created by Taha Doğan Güneş on 29/06/15.
//  Copyright (c) 2015 Taha Doğan Güneş. All rights reserved.
//

import Foundation


class BeaconService {
    var nkit = NetKit()
    
    var onSuccessCallback: (([Beacon])->())?
    var onErrorCallback: (()->())?
    
    init(successCallback: (([Beacon])->())? = nil, errorCallback: (()->())? = nil) {
        self.onSuccessCallback = successCallback
        self.onErrorCallback = errorCallback
    }
    
    func setURL(url:String){
        nkit.baseURL = url
        if !IS_TARGET_IPHONE_SIMULATOR {
            nkit.baseURL = url.stringByReplacingOccurrencesOfString("127.0.0.1", withString: "192.168.1.109")
        }
    }
    
    
    func fetchBeacons(){
        let apiMethod = "/api/beacons"
        nkit.get(url: apiMethod, completionHandler: self.onSuccess, errorHandler: self.onError)
    }
    
    func onError(nkerror:NKError, nserror:NSError?) {
        println("\(nkerror): \(nserror)")
        
        if let callback = self.onErrorCallback {
            callback()
        }
    }
    
    func onSuccess(response:NKResponse) {
        println(response.string!)
        var beacons:[Beacon] = []
        if let callback = self.onSuccessCallback,
            let json = response.json,
            let jsonArray = json.asArray {
                for jsonObject in jsonArray {
                    if let name = jsonObject["name"].asString,
                        let uuid = jsonObject["uuid"].asString {
                            
                            var beacon = Beacon(name: name, uuid: uuid)
                            beacons.append(beacon)
                            
                            
                    }
                }
                callback(beacons)
        }
        
        
    }
    
    
    
}
