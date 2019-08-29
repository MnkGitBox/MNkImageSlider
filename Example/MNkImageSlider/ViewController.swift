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
    
    private var proImgSlider:MNkImageSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSliderStoryBoard.register(slider: SliderSample.self, with: "test")
        imageSliderStoryBoard.datasource = self
        imageSliderStoryBoard.delegate = self
//        imageSliderStoryBoard.imagesData = data
        
        proImgSlider = MNkImageSlider()
        proImgSlider.register(slider: SliderSample.self, with: "test")
        proImgSlider.datasource = self
        proImgSlider.delegate = self
//        proImgSlider.imagesData = data
        proImgSlider.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(proImgSlider)
        NSLayoutConstraint.activate([proImgSlider.topAnchor.constraint(equalTo: imageSliderStoryBoard.bottomAnchor,
                                                                       constant: 20),
                                     proImgSlider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     proImgSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                     proImgSlider.heightAnchor.constraint(equalToConstant: 200)])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageSliderStoryBoard.playSlider()
        imageSliderStoryBoard.isRepeat = true
        imageSliderStoryBoard.delay = 5
        imageSliderStoryBoard.indicator.selectedColor = .red
        imageSliderStoryBoard.sliderSize = .two
        imageSliderStoryBoard.isActiveIndicator = true
        
        proImgSlider.playSlider()
        proImgSlider.isRepeat = true
        proImgSlider.delay = 5
        proImgSlider.indicator.selectedColor = .red
        proImgSlider.sliderSize = .two
        proImgSlider.isActiveIndicator = true
        proImgSlider.repeatFactor = 2
    }
    
    
}


extension ViewController:MNkSliderDataSource,MNkSliderDelegate{
//    func mnkSliderNumberOfItems(in slider: Slider) -> Int {
//        return data.count
//    }
    
    func mnkSliderNumberOfItems(in slider: MNkImageSlider) -> Int {
         return data.count
    }
//    func mnkSliderItemCell(in slider: Slider, for indexPath: IndexPath) -> SliderCell? {
//        let cell = slider.dequeSliderCell(with: "test", for: indexPath) as! SliderSample
//        cell.label.text = "\(indexPath)"
//        cell.imageData = data[indexPath.item]
//        return cell
//    }
    
    func mnkSliderItemCell(in slider: MNkImageSlider, for indexPath: IndexPath) -> SliderCell{
        let cell = slider.dequeSliderCell(with: "test", for: indexPath) as! SliderSample
        cell.label.text = "\(indexPath)"
        cell.imageData = data[indexPath.item]
        return cell
    }
    
    func userScrolled(_ sliderData: Any?, atCellIndex indexPath: IndexPath, of cell: SliderCell) {
        print("Scrolled: ",indexPath.item)
    }
    
//    func mnkSliderSizeForItem(at indexPath: IndexPath, of collectionView: UICollectionView) -> CGSize {
//        return CGSize.init(width: collectionView.bounds.size.width/2, height: collectionView.bounds.size.height)
//    }
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
