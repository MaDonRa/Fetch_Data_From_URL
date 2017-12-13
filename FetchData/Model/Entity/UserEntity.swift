//
//  UserEntity.swift
//  FetchData
//
//  Created by Sakkaphong Luaengvilai on 12/1/2560 BE.
//  Copyright © 2560 MaDonRa. All rights reserved.
//

import Foundation

class UserEntity : NSObject {
    
    let User_Name : String
    let User_Image : String

    init(User_json : [String : Any]) {
        
        self.User_Name = User_json["display_name"] as? String ?? ""
        self.User_Image = User_json["profile_picture_url"] as? String ?? ""
        
    }
    
}
