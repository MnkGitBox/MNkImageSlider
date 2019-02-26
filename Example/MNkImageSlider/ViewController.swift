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
    
    let data =  [#imageLiteral(resourceName: "dog"),#imageLiteral(resourceName: "birds"),#imageLiteral(resourceName: "reptile")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
         imageSliderStoryBoard.slider.register(slider: SliderSample.self, with: "test")
         imageSliderStoryBoard.sliderDataSource = self
         imageSliderStoryBoard.imagesData = data
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageSliderStoryBoard.playSlider()
        imageSliderStoryBoard.isRepeat = true
        imageSliderStoryBoard.delay = 5
        imageSliderStoryBoard.indicator.selectedColor = .red
        imageSliderStoryBoard.size = .two
        imageSliderStoryBoard.slider.imageContentMode = .scaleAspectFill
        
    }
    
    
}


extension ViewController:MNkSliderDataSource{
    func mnkSliderItemCell(in slider: Slider, for indexPath: IndexPath) -> SliderCell? {
        let cell = slider.dequeSliderCell(with: "test", for: indexPath) as! SliderSample
        cell.label.text = "\(indexPath)"
        cell.imageData = data[indexPath.item]
        return cell
    }
}






class SliderSample:SliderCell{
    
    
    var label:UILabel!
    
    private func createViews(){
        label = UILabel()
        label.textColor = .red
        label.text = "Testing..."
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func inserAndLayoutSubviews(){
        addSubview(label)
        NSLayoutConstraint.activate([label.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     label.centerYAnchor.constraint(equalTo: centerYAnchor)])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        inserAndLayoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
