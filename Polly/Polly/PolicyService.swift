//
//  PolicyService.swift
//  Polly
//
//  Created by Taha Doğan Güneş on 18/06/15.
//  Copyright (c) 2015 Taha Doğan Güneş. All rights reserved.
//

import Foundation

class PolicyService {
    var nkit = NetKit()
    
    var onSuccessCallback: (([Area])->())?
    var onErrorCallback: (()->())?
    
    init(successCallback: (([Area])->())? = nil, errorCallback: (()->())? = nil) {
        self.onSuccessCallback = successCallback
        self.onErrorCallback = errorCallback
    }
    
    func setURL(url:String){
        nkit.baseURL = url
        if !IS_TARGET_IPHONE_SIMULATOR {
            nkit.baseURL = url.stringByReplacingOccurrencesOfString("127.0.0.1", withString: "192.168.1.44")
        }

    }
    
    func fetchPolicies(){
        let apiMethod = "/api/policies/all"
        nkit.get( url: apiMethod, completionHandler: self.onSuccess, errorHandler: self.onError)
    }
    
    func onError(nkerror:NKError, nserror:NSError?) {
        println("\(nkerror): \(nserror)")
        
        if let callback = self.onErrorCallback {
            callback()
        }
    }
    
    func onSuccess(response:NKResponse) {
        println(response.string!)
        var areas:[Area] = []
        if let callback = self.onSuccessCallback,
           let json = response.json,
           let jsonArray = json.asArray {
                for jsonObject in jsonArray {
                    if let url = jsonObject["url"].asString,
                       let name = jsonObject["name"].asString,
                       let policies = jsonObject["policies"].asArray {
                        
                       var area = Area(name: name, url: url, level: "N/A")
                       for jsonPolicy in policies {
                            let policy = Policy(policyJSON: jsonPolicy)
                            area.addPolicy(policy)
                       }
                       areas.append(area)
                            
                            
                    }
                }
                callback(areas)
            }
            

    }

    
}
