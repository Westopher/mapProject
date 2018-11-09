//
//  PopVC.swift
//  mapsProject
//
//  Created by West Kraemer on 11/9/18.
//  Copyright © 2018 West Kraemer. All rights reserved.
//

import UIKit

class PopVC: UIViewController {

    @IBOutlet weak var popImageView: UIImageView!
    
    var passedImage: UIImage!
    
    func initData(forImage image: UIImage) {
        self.passedImage = image
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
    }
  

}
