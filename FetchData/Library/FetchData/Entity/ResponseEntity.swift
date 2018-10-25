//
//  ResponseEntity.swift
//  Wala-R2
//
//  Created by Sakkaphong on 1/9/18.
//  Copyright © 2018 Sakkaphong. All rights reserved.
//

struct ResponseEntity {
    
    let Success : Bool
    let Error : String
    let Data : [String : Any]
    let DataString : String
    let DataInt : Int
    let DataArray : [[String : Any]]
    let DataBool : Bool
    let Total : Int
    let Status : Int
    
    init(json : [String : Any]) {
        self.Success = json["success"] as? Bool ?? false
        self.Error = json["errors"] as? String ?? "error"
        self.Data = json["data"] as? [String : Any] ?? [:]
        self.DataString = json["data"] as? String ?? ""
        self.DataInt = json["data"] as? Int ?? 0
        self.DataArray = json["data"] as? [[String : Any]] ?? []
        self.DataBool = json["data"] as? Bool ?? false
        self.Total = json["total"] as? Int ?? 0
        self.Status = json["status"] as? Int ?? 0
    }
}
