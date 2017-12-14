//
//  ViewController.swift
//  FetchData
//
//  Created by Sakkaphong Luaengvilai on 12/1/2560 BE.
//  Copyright © 2560 MaDonRa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var CenterImageView: UIImageView!
    
    private let Model = Model_API.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Model.Fetch_Video_List { (status) in
            
            guard status == true else { return }
            
            for data in self.Model.Video_List
            {
                print(data.Video_Name)
                print(data.Video_Status)
                print(data.Video_Viewer)
                
                print(data.User_Name)
                
                self.Model.Fetch_Image(Image_URL: data.User_Image, completion: { (image) in
                    self.CenterImageView.image = image
                })
                
            }
            
        }
        
    }
    
}

