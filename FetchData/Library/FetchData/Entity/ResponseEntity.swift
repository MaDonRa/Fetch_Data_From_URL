//
//  ResponseEntity.swift
//  Wala-R2
//
//  Created by Sakkaphong on 1/9/18.
//  Copyright © 2018 Sakkaphong. All rights reserved.
//

import Foundation

class ResponseEntity : NSObject {
    
    let Success : Bool
    let Error : String
    let Data : [String : AnyObject]
    let DataString : String
    let DataArray : [[String : AnyObject]]
    let Total : Int
    let Status : Int
    
    init(json : [String : AnyObject]) {
        self.Success = json["success"] as? Bool ?? false
        self.Error = json["Errorss"] as? String ?? "Error : nil by MaDonRa"
        self.Data = json["Data"] as? [String : AnyObject] ?? [:]
        self.DataString = json["Data"] as? String ?? ""
        self.DataArray = json["items"] as? [[String : AnyObject]] ?? [[:]]
        self.Total = json["Total"] as? Int ?? 0
        self.Status = json["Status"] as? Int ?? 0
    }
    
}
