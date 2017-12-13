//
//  ManageRequestData.swift
//  FetchData
//
//  Created by Sakkaphong Luaengvilai on 12/1/2560 BE.
//  Copyright © 2560 MaDonRa. All rights reserved.
//

import Foundation

protocol FetchDataDelegate {
    func FetchData(url : String , UseCacheIfHave: Bool , completion:@escaping (Data?)->())
}

class FetchModel : FetchDataDelegate {
    
    func FetchData(url : String , UseCacheIfHave: Bool , completion:@escaping (Data?)->())
    {
        
        guard Reachability.isConnectedToNetwork() == true , let link_url = URL(string: url) else { return completion(nil) }
        
        let task = URLSession.shared.dataTask(with: (UseCacheIfHave ? URLRequest(url: link_url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 30) : URLRequest(url: link_url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData , timeoutInterval: 30))) {
            (data, response, error) -> Void in
            
            guard error == nil , let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode == 200 , data != nil  else {
                
                print("Check Internet Connection not return [200] : \(error.debugDescription)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) { self.FetchData(url : url , UseCacheIfHave : UseCacheIfHave ,completion: completion) }
                
                return completion(nil)
                
            }
            
            DispatchQueue.main.async { return completion(data) }
            
        }
        
        task.resume()
        
    }
    
}


