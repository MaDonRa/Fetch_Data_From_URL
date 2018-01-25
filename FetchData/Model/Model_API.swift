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
    
    private let Fetch : FetchFullAccessDelegate = FetchModel()
    
    public var Video_List = [VideoEntity]()
    
    func Fetch_Video_List(completion:@escaping (Int,String)->()) {
        self.Fetch.GetData(url: "https://api.vibie.live/v1/lives", UseCacheIfHave: false) { (response) in
            
            for a in response.DataArray {
                self.Video_List.append(VideoEntity(Video_json: a))
            }
            
            return completion(response.Status,response.Error)
        }
    }
    
    func Update_User_Profile(Name: String , Last_Name: String , E_mail: String , Gender: String , BirthDate : String, Image_Url : String, completion:@escaping (Int,String)->()) {
        self.Fetch.PostData(url: "www.eiei.com", PostArray: [
            "Name" : Name,
            "LastName" : Last_Name,
            "Email" : E_mail,
            "Gender" : Gender,
            "BirthDate" : BirthDate,
            "ImageUrl" : Image_Url]
        ) { (response) in
            
            return completion(response.Status,response.Error)
        }
    }
    
    func Update_User_Image_Profile(image : UIImage? , completion:@escaping (Int,String)->()) {
        guard let image = image , let ImageJPEG = UIImageJPEGRepresentation(image, 0.5) else { return }
        self.Fetch.PostDataWithImage(url: "www.eiei.com/image", Post: ImageJPEG) { (response) in
            
            
            return completion(response.Status,response.Error)
        }
    }
    
    lazy private var Cahce_Image:NSCache = NSCache<NSString , UIImage>()
    
    func Fetch_Image(Image_URL : String , completion:@escaping (UIImage)->()) {
        
        if let image = Cahce_Image.object(forKey: NSString(string: Image_URL)) {
            return completion(image)
        }
        else {
            self.Fetch.GetImageData(url: Image_URL, UseCacheIfHave: true, completion: { (data) in
                
                guard let image = UIImage(data: data) else { return }
                
                self.Cahce_Image.setObject(image, forKey: NSString(string: Image_URL))
                
                OperationQueue.main.addOperation { return completion(image) }
                
            })
        }
    }
}

