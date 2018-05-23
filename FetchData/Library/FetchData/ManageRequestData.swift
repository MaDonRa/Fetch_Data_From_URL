//
//  ManageRequestData.swift
//  FetchData
//
//  Created by Sakkaphong Luaengvilai on 12/1/2560 BE.
//  Copyright © 2560 MaDonRa. All rights reserved.
//

import Foundation

typealias FetchFullGetDelegate = FetchGetDelegate & FetchGetImageDelegate
typealias FetchGetAndPostDelegate = FetchGetDelegate & FetchPostDelegate & FetchGetImageDelegate
typealias FetchFullAccessDelegate = FetchGetDelegate & FetchPostDelegate & FetchPostImageDelegate & FetchGetImageDelegate

protocol FetchGetDelegate {
    func GetData(url : String , UseCacheIfHave: Bool , completion:@escaping (ResponseEntity)->())
}

protocol FetchGetImageDelegate {
    func GetImageData(url : String , UseCacheIfHave: Bool , completion:@escaping (Data)->())
}

protocol FetchPostDelegate {
    func PostData(url : String , PostArray : [String : Any] , completion:@escaping (ResponseEntity)->())
}

protocol FetchPostImageDelegate {
    func PostDataWithImage(url : String , Post : Data , completion:@escaping (ResponseEntity)->())
}

internal enum HTTPMethod : String {
    case GET , POST , DELETE , PATCH , PUT
}

protocol FetchRestfulDelegate {
    func RestfulPostData(url : String , Method : HTTPMethod , UseCacheIfHave: Bool , PostArray : [String : Any] , completion:@escaping (ResponseEntity)->())
}

class FetchModel : FetchGetDelegate , FetchGetImageDelegate , FetchPostDelegate , FetchPostImageDelegate , FetchRestfulDelegate {
    
    private var CheckFetched = [String:Int]()
    
    func GetData(url : String , UseCacheIfHave: Bool , completion:@escaping (ResponseEntity)->()) {
        
        guard Reachability.isConnectedToNetwork() == true , let link_url = URL(string: url) else { return }

        let request = NSMutableURLRequest(url: link_url, cachePolicy: (UseCacheIfHave ? .returnCacheDataElseLoad : .reloadIgnoringLocalAndRemoteCacheData), timeoutInterval: 15)
        
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request as URLRequest) { [weak self]
            (data, response, error) -> Void in
            
            guard error == nil , (response as? HTTPURLResponse)?.statusCode == 200 , let data = data , let json = try? JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String : AnyObject] , let ConvertJson = json else {
                
                print("Check Internet Connection not return [200] : \(url) : \(error.debugDescription)")
                guard let check = self?.CheckFetched[url] , check < 3 else {
                    if self?.CheckFetched[url] == nil {
                        self?.CheckFetched[url] = 0
                    }
                    return
                }
                self?.CheckFetched[url] = check + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) { self?.GetData(url: url, UseCacheIfHave: UseCacheIfHave, completion: completion) }
                
                return
            }
            
            DispatchQueue.main.async {
                return completion(ResponseEntity(json: ConvertJson))
            }
            
        }
        
        task.resume()
        
    }
    
    func GetImageData(url : String , UseCacheIfHave: Bool , completion:@escaping (Data)->()) {
        
        guard Reachability.isConnectedToNetwork() == true , let link_url = URL(string: url) else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: link_url, cachePolicy: UseCacheIfHave ? .returnCacheDataElseLoad : .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)) { [weak self]
            (data, response, error) -> Void in
            
            guard error == nil , (response as? HTTPURLResponse)?.statusCode == 200 , let data = data else {
                
                print("Check Internet Connection not return [200] : \(url) : \(error.debugDescription)")
                guard let check = self?.CheckFetched[url] , check < 3 else {
                    if self?.CheckFetched[url] == nil {
                        self?.CheckFetched[url] = 0
                    }
                    return
                }
                self?.CheckFetched[url] = check + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) { self?.GetImageData(url : url , UseCacheIfHave : UseCacheIfHave ,completion: completion) }
                return
                
            }
            
            DispatchQueue.main.async { return completion(data) }
            
        }
        
        task.resume()
        
    }
    
    func PostData(url : String , PostArray : [String : Any] , completion:@escaping (ResponseEntity)->()) {
        
        guard Reachability.isConnectedToNetwork() == true , let link_url = URL(string: url) , let Body = try? JSONSerialization.data(withJSONObject: PostArray, options: .prettyPrinted) else { return }

        let request = NSMutableURLRequest(url: link_url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.httpBody = Body
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request as URLRequest) { [weak self]
            (data, response, error) -> Void in
            
            guard error == nil , (response as? HTTPURLResponse)?.statusCode == 200 , let data = data , let json = try? JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String : AnyObject] , let ConvertJson = json else {
                
                print("Check Internet Connection not return [200] : \(url) : \(error.debugDescription)")
                guard let check = self?.CheckFetched[url] , check < 3 else {
                    if self?.CheckFetched[url] == nil {
                        self?.CheckFetched[url] = 0
                    }
                    return
                }
                self?.CheckFetched[url] = check + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) { self?.PostData(url : url , PostArray : PostArray  ,completion: completion) }

                return
            }
            
            DispatchQueue.main.async {
                return completion(ResponseEntity(json: ConvertJson))
            }
            
        }
        
        task.resume()
        
    }
    
    func PostDataWithImage(url : String , Post : Data , completion:@escaping (ResponseEntity)->()) {
        
        guard Reachability.isConnectedToNetwork() == true , let link_url = URL(string: url) else { return }
        let boundary = UUID().uuidString // need only 36 character
        
        let body = NSMutableData();
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\"\r\n")
        body.appendString("Content-Type: \r\n\r\n")
        body.append(Post)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        
        let request = NSMutableURLRequest(url: link_url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.httpBody = body as Data
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { [weak self]
            (data, response, error) -> Void in
            
            guard error == nil , (response as? HTTPURLResponse)?.statusCode == 200 , let data = data , let json = try? JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String : AnyObject] , let ConvertJson = json else {
                
                print("Check Internet Connection not return [200] : \(url) : \(error.debugDescription)")
               
                guard let check = self?.CheckFetched[url] , check < 3 else {
                    if self?.CheckFetched[url] == nil {
                        self?.CheckFetched[url] = 0
                    }
                    return
                }
                self?.CheckFetched[url] = check + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) { self?.PostDataWithImage(url : url , Post : Post  ,completion: completion) }
                
                return
            }
            
            DispatchQueue.main.async {
                return completion(ResponseEntity(json: ConvertJson))
            }
            
        }
        
        task.resume()
        
    }
    
    func RestfulPostData(url : String , Method : HTTPMethod , UseCacheIfHave: Bool , PostArray : [String : Any] , completion:@escaping (ResponseEntity)->()) {
        
        guard Reachability.isConnectedToNetwork() == true , let link_url = URL(string: url) else { return }
        
        let request = NSMutableURLRequest(url: link_url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
        request.httpMethod = Method.rawValue
        
        if !PostArray.isEmpty {
            do {
                let Body = try JSONSerialization.data(withJSONObject: PostArray, options: .prettyPrinted)
                request.httpBody = Body
            } catch {
                print(error)
                return
            }
        }

        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { [weak self]
            (data, response, error) -> Void in
            
            guard error == nil , (response as? HTTPURLResponse)?.statusCode == 200 , let data = data , let json = try? JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String : AnyObject] , let ConvertJson = json else {
                
                print("Check Internet Connection not return [200] : \(url) : \(error.debugDescription)")
                guard let check = self?.CheckFetched[url] , check < 3 else {
                    if self?.CheckFetched[url] == nil {
                        self?.CheckFetched[url] = 0
                    }
                    return
                }
                self?.CheckFetched[url] = check + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) { self?.PostData(url : url , PostArray : PostArray  ,completion: completion) }
                
                return
            }
            
            DispatchQueue.main.async {
                return completion(ResponseEntity(json: ConvertJson))
            }
            
        }
        
        task.resume()
        
    }
    
}

extension NSMutableData {
    
    func appendString(_ string: String) {
        guard let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) else { return }
        append(data)
    }
}


