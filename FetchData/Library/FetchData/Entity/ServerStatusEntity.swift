//
//  ServerStatusEntity.swift
//  Box24
//
//  Created by Sakkaphong Luaengvilai on 9/7/2561 BE.
//  Copyright © 2561 MaDonRa. All rights reserved.
//

enum ServerStatusCodeEntity : Int {
    case    OK = 200 ,
            Created = 201 ,
            No_Content = 204 ,
            Reset_Content = 205 ,
            Bad_Request = 400 ,
            Unauthorized = 401 ,
            Forbidden = 403 ,
            Not_Found = 404 ,
            Internal_Server_Error = 500 ,
            Service_Unavailable = 503 ,
            Check_Internet = 999
}
