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
    
    private let Fetch : FetchRestfulAndImageDelegate = FetchModel()

    internal func Get_Laundry_Note_Add(CategoryID : Int , Note : String , Image : Data? , completion:@escaping (ServerStatusCodeEntity,String)->()) {
        
        self.Fetch.RestfulPostData(url: Rounter.BaseUrl+Rounter.SubDomain+Rounter.API_Version+Path.Laundry_Note,
                                   Method: .POST,
                                   UseCacheIfHave: false,
                                   Body: ["clean_type":0,
                                          "note":Note,
                                          "image":Image ?? NSNull()
            ]
        , Animation: true)  { (response, status) in
            
            return completion(status,response.Error)
        }
    }

    lazy private var Cahce_Image:NSCache = NSCache<NSString , UIImage>()
    
    internal func Fetch_Image(Image_URL : String , completion:@escaping (UIImage)->()) {
        
        if let image = Cahce_Image.object(forKey: NSString(string: Image_URL)) {
            return completion(image)
        } else {
            self.Fetch.GetImageData(url: Image_URL, UseCacheIfHave: true, completion: { [unowned self] (data) in
                
                guard let image = UIImage(data: data) else { return }
                
                self.Cahce_Image.setObject(image, forKey: NSString(string: Image_URL))
                
                OperationQueue.main.addOperation { return completion(image) }
                
            })
        }
    }
}

