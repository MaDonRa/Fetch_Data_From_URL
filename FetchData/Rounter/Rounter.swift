//
//  Rounter.swift
//  Box24
//
//  Created by Sakkaphong Luaengvilai on 9/7/2561 BE.
//  Copyright © 2561 MaDonRa. All rights reserved.
//

import Foundation

struct Rounter {
    static let Domain : String = "box24-backend.herokuapp.com"
    static let BaseUrl : String = "https://" + Rounter.Domain
    static let SubDomain : String = "/api/"
    static let API_Version : String = "v2/"
}

struct Path {
    static let Laundry_Note : String = "Laundry_Note"
}
