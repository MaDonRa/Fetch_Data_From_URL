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
    
    private weak var Model = Model_API.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Model?.Fetch_Image(Image_URL: "https://cdn1.iconfinder.com/data/icons/ninja-things-1/1772/ninja-simple-512.png", completion: { [weak self]  (image) in
            guard let self = self else { return }
            self.CenterImageView.image = image
        })
    }
}

