//
//  ManageRequestData.swift
//  FetchData
//
//  Created by Sakkaphong Luaengvilai on 12/1/2560 BE.
//  Copyright © 2560 MaDonRa. All rights reserved.
//

import Foundation
//import SVProgressHUD

typealias FetchRestfulAndImageDelegate = FetchRestfulDelegate & FetchGetImageDelegate

protocol FetchGetImageDelegate {
    func GetImageData(url : String , UseCacheIfHave: Bool , completion:@escaping (Data)->())
}

internal enum HTTPMethod : String {
    case GET , POST , DELETE , PATCH , PUT
}

protocol FetchRestfulDelegate {
    func RestfulPostData(url : String , Method : HTTPMethod , UseCacheIfHave: Bool , Body : [String : Any]? , Animation : Bool, completion:@escaping (ResponseEntity,ServerStatusCodeEntity)->())
}

class FetchModel : NSObject , FetchGetImageDelegate , FetchRestfulDelegate {
    
    private var CheckFetched = [String:Int]()
    private var JSONFormat : Bool = false
    
    func GetImageData(url : String , UseCacheIfHave: Bool , completion:@escaping (Data)->()) {
        
        guard Reachability.isConnectedToNetwork() == true , let link_url = URL(string: url) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let task = urlSession.dataTask(with: URLRequest(url: link_url, cachePolicy: UseCacheIfHave ? .returnCacheDataElseLoad : .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)) { [unowned self]
                (data, response, error) -> Void in
                
                guard error == nil , (response as? HTTPURLResponse)?.statusCode == 200 , let data = data else {
                    
                    print("Check Internet Connection not return [200] : \(url) : \(error.debugDescription)")
                    guard let check = self.CheckFetched[url] , check < 3 else {
                        if self.CheckFetched[url] == nil {
                            self.CheckFetched[url] = 0
                        }
                        return
                    }
                    self.CheckFetched[url] = check + 1
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 10) { self.GetImageData(url : url , UseCacheIfHave : UseCacheIfHave ,completion: completion) }
                    return
                    
                }
                
                DispatchQueue.main.async {
                    self.CheckFetched.removeValue(forKey: url)
                    return completion(data)
                }
                
            }
            
            task.resume()
        }
    }
    
    func RestfulPostData(url : String , Method : HTTPMethod , UseCacheIfHave: Bool , Body : [String : Any]? , Animation : Bool , completion:@escaping (ResponseEntity,ServerStatusCodeEntity)->()) {
        
        guard Reachability.isConnectedToNetwork() == true , let link_url = URL(string: url) else {
            let Code = ResponseEntity(json:
                ["errors" : "Your internet service have problem. Please, check your connection","status" : 999]
            )
            return completion(Code,ServerStatusCodeEntity.Check_Internet)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            
            
            //if Animation { OperationQueue.main.addOperation({ SVProgressHUD.show() }) }
            
            let request = NSMutableURLRequest(url: link_url, cachePolicy: UseCacheIfHave ? .returnCacheDataElseLoad : .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
            request.httpMethod = Method.rawValue
            
            debugPrint("Fetch URL : \(url) \n" , "Body : \(Body ?? [:])")
            
            if self.JSONFormat {
                if let body = Body , !body.isEmpty {
                    do {
                        let Body = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                        request.httpBody = Body
                    } catch {
                        print(error)
                        return
                    }
                }
                
                //request.setValue(Cache.SelectedLanguage == ConfigOther.LanguageName.Thai.Language ? "TH" : "EN", forHTTPHeaderField: "Accept-Language")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            } else {
                let boundary:String = UUID().uuidString
                
                let ConvertBody = NSMutableData();
                
                if let body = Body , !body.isEmpty {
                    for (key,value) in body {
                        if value is NSNull {
                            
                        } else {
                            
                            ConvertBody.appendString("--\(boundary)\r\n")
                            ConvertBody.appendString("Content-Disposition: form-data; name=\"\(key)\"")
                            
                            if let File = value as? Data {
                                ConvertBody.appendString("; filename=\"Image.jpeg\"\r\n")
                                ConvertBody.appendString("Content-Type: image/jpeg\r\n\r\n")
                                ConvertBody.append(File)
                                ConvertBody.appendString("\r\n")
                            } else if let FileArray = value as? [Data] {
                                for File in FileArray {
                                    ConvertBody.appendString("; filename=\"Image.jpeg\"\r\n")
                                    ConvertBody.appendString("Content-Type: image/jpeg\r\n\r\n")
                                    ConvertBody.append(File)
                                    ConvertBody.appendString("\r\n")
                                }
                            } else if let DataArray = value as? [Any] {
                                var StartLoop : Bool = false
                                for Data in DataArray {
                                    if !StartLoop {
                                        ConvertBody.appendString("\r\n\r\n\(Data)")
                                    } else {
                                        ConvertBody.appendString("--\(boundary)\r\n")
                                        ConvertBody.appendString("Content-Disposition: form-data; name=\"\(key)\"")
                                        ConvertBody.appendString("\r\n\r\n\(Data)")
                                    }
                                    StartLoop = true
                                }
                            } else {
                                ConvertBody.appendString("\r\n\r\n\(value)")
                            }
                        }
                    }
                    ConvertBody.appendString("--\(boundary)--\r\n")
                    
                    request.httpBody = ConvertBody as Data
                }
                
                //request.setValue(Cache.SelectedLanguage == ConfigOther.LanguageName.Thai.Language ? "TH" : "EN", forHTTPHeaderField: "Accept-Language")
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            }
            
//            if Cache.TokenLoginFromServer.isEmpty {
//                request.setValue("BOX24-JWT \(Cache.TokenAnonymousFromServer)", forHTTPHeaderField: "Authorization")
//            } else {
//                request.setValue("BOX24-JWT \(Cache.TokenLoginFromServer)", forHTTPHeaderField: "Authorization")
//            }
            
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let task = urlSession.dataTask(with: request as URLRequest) { [unowned self]
                (data, response, error) -> Void in
                
                guard error == nil , let ServerStatusCode = ServerStatusCodeEntity(rawValue: (response as? HTTPURLResponse)?.statusCode ?? 0) , ServerStatusCode.rawValue <= ServerStatusCodeEntity.Internal_Server_Error.rawValue , let data = data , let json = try? JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [String : Any] , let ConvertJson = json else {
                    
                    print("Check Internet Connection return [\((response as? HTTPURLResponse)?.statusCode ?? 0)] : \n \(url) \n ----- \(error.debugDescription)")
                    guard let check = self.CheckFetched[url] , check < 3 else {
                        if self.CheckFetched[url] == nil {
                            self.CheckFetched[url] = 0
                        }
                        return
                    }
                    self.CheckFetched[url] = check + 1
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 10, execute: {
                        self.RestfulPostData(url: url , Method: Method, UseCacheIfHave: UseCacheIfHave, Body: Body , Animation : Animation , completion: completion)
                    })
                    //OperationQueue.main.addOperation({ SVProgressHUD.dismiss() })
                    return
                }
                
                debugPrint(ConvertJson)
                DispatchQueue.main.async {
                    //OperationQueue.main.addOperation({ SVProgressHUD.dismiss() })
                    self.CheckFetched.removeValue(forKey: url)
                    self.CheckErrorCode401(status: ServerStatusCode.rawValue, completion: {
                        //OperationQueue.main.addOperation({ SVProgressHUD.show() })
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 10, execute: {
                            self.RestfulPostData(url: url , Method: Method, UseCacheIfHave: UseCacheIfHave, Body: Body , Animation : Animation , completion: completion)
                        })
                    })
                    return completion(ResponseEntity(json: ConvertJson),ServerStatusCode)
                }
            }
            
            task.resume()
        }
    }
}

extension FetchModel {
    func CheckErrorCode401 (status : Int, completion:@escaping ()->()) {
        guard status == ServerStatusCodeEntity.Unauthorized.rawValue else { return }
        
    }
}

extension FetchModel : URLSessionDelegate {
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard challenge.previousFailureCount == 0 else {
            challenge.sender?.cancel(challenge)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
            && challenge.protectionSpace.serverTrust != nil
            && challenge.protectionSpace.host == Rounter.Domain {
            let proposedCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, proposedCredential)
        }
    }
}

extension NSMutableData {
    
    func appendString(_ string: String) {
        guard let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) else { return }
        append(data)
    }
}


