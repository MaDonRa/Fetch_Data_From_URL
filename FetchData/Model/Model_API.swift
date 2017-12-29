//
//  Model_API.swift
//  FetchData
//
//  Created by Sakkaphong Luaengvilai on 12/1/2560 BE.
//  Copyright © 2560 MaDonRa. All rights reserved.
//

import UIKit

class Model_API: NSObject {
    
    static var sharedInstance = Model_API()
    
    private let Fetch : FetchDataDelegate = FetchModel()
    
    public var Video_List = [VideoEntity]()
    
    func Fetch_Video_List(completion:@escaping (Bool)->())
    {
        self.Fetch.FetchData(url: "https://api.vibie.live/v1/lives" , UseCacheIfHave: false) { (data) in
            
            guard let data = data , let json = try? JSONSerialization.jsonObject(with: data, options:.allowFragments) as? NSDictionary , let Event = json?["items"] as? [[String: AnyObject]] else { return completion(false) }
            // ขึ้นอยู่กับรูปแบบ array ที่มาจาก API - array 1 D / array 2 D
            
            for a in Event
            {
                
                self.Video_List.append(VideoEntity.init(Video_json: a))
                
            }
            
            return completion(true)
            
        }
    }
    
//    func Fetch_Video_List(completion:@escaping (Bool)->())
//    {
//        self.Fetch.FetchData(url: "https://www.estopolis.com/allreview" , UseCacheIfHave: false) { (data) in
//
//            guard let data = data , let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String:AnyObject]] else { return completion(false) }
//
//
//
//            for a in json!
//            {
//                print(a)
//
//                if let text = a["MetaSEO"] as? [String:Any]
//                {
//
//                    print(text["Description"] as? String)
//
//                }
//            }
//
//            return completion(true)
//
//        }
//    }
    
    lazy private var Cahce_Image:NSCache = NSCache<NSString , UIImage>()
    
    func Fetch_Image(Image_URL : String , completion:@escaping (UIImage)->())
    {
        
        if let image = Cahce_Image.object(forKey: NSString(string: Image_URL))
        {
            return completion(image)
        }
        else
        {
            
            self.Fetch.FetchData(url: Image_URL , UseCacheIfHave: true) { (data) in
                
                guard let data = data , let image = UIImage(data: data) else { return }
                
                self.Cahce_Image.setObject(image, forKey: NSString(string: Image_URL))
                
                OperationQueue.main.addOperation { return completion(image) }
                
            }
            
        }
        
    }
    
}
