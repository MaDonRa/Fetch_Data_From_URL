//
//  UserEntity.swift
//  FetchData
//
//  Created by Sakkaphong Luaengvilai on 12/1/2560 BE.
//  Copyright © 2560 MaDonRa. All rights reserved.
//

import Foundation

class VideoEntity : UserEntity {
    
    let Video_Name : String
    let Video_Status : String
    let Video_Viewer : Int
    
    init(Video_json : [String : Any]) {
        
        self.Video_Status = Video_json["type"] as? String ?? ""
        self.Video_Name = Video_json["title"] as? String ?? ""
        self.Video_Viewer = Video_json["viewer_count"] as? Int ?? 0
        
        super.init(User_json: Video_json["user"] as? [String:Any] ?? [:])
    }
    
}
