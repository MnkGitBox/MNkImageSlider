//
//  ViewController.swift
//  MNkImageSlider
//
//  Created by m.nadeeshan@yahoo.co.uk on 08/07/2018.
//  Copyright (c) 2018 m.nadeeshan@yahoo.co.uk. All rights reserved.
//

import UIKit
import MNkImageSlider

class ViewController: UIViewController {

    @IBOutlet weak var imageSliderStoryBoard: MNkImageSlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSliderStoryBoard.imagesData = [#imageLiteral(resourceName: "dog"),#imageLiteral(resourceName: "birds"),#imageLiteral(resourceName: "reptile")]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageSliderStoryBoard.startSliderAnimation()
    }
    
    
}

 
