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
    
//    let data =  [#imageLiteral(resourceName: "dog"),#imageLiteral(resourceName: "birds"),#imageLiteral(resourceName: "reptile"),#imageLiteral(resourceName: "reptile"),#imageLiteral(resourceName: "reptile"),#imageLiteral(resourceName: "reptile"),#imageLiteral(resourceName: "dog"),#imageLiteral(resourceName: "dog"),#imageLiteral(resourceName: "dog")]
    let data = [UIImage]()
    
    private var proImgSlider:MNkImageSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSliderStoryBoard.register(slider: SliderSample.self, with: "test")
        imageSliderStoryBoard.datasource = self
        imageSliderStoryBoard.slideActivePosition = .middle
        
        
        proImgSlider = MNkImageSlider.init(frame: .zero, .forward)
        proImgSlider.register(slider: SliderSample.self, with: "test")
        proImgSlider.datasource = self
        proImgSlider.delegate = self
        proImgSlider.slideActivePosition = .middle
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
//        imageSliderStoryBoard.isAnimate = true
//        imageSliderStoryBoard.isRepeat = true
        imageSliderStoryBoard.delay = 2
        imageSliderStoryBoard.indicators.selectedColor = .red
        imageSliderStoryBoard.isActiveIndicator = true
        imageSliderStoryBoard.minScaleFactor = 0.2
        imageSliderStoryBoard.isPagingEnabled = true
        
        
        proImgSlider.indicators.selectedColor = .red
        proImgSlider.isActiveIndicator = true
        proImgSlider.minScaleFactor  = 0.5
        proImgSlider.indicatorAlign = .right
        proImgSlider.indicatorBottomPadding = 0
        proImgSlider.adjustIndicatorWidthAutomatically = false
        proImgSlider.indicators.padding = 4
        proImgSlider.indicators.indicatorViewSize = 6
        proImgSlider.indicatorMaxWidth = 64
        
        let view = UIView()
        view.backgroundColor = .green
        proImgSlider.indicators.insetBackground(view)
    }
    
    
}


extension ViewController:MNkSliderDataSource,MNkSliderDelegate{

    func mnkSliderNumberOfItems(in slider: MNkImageSlider) -> Int {
         return data.count
    }
    
    func mnkSliderItemCell(in slider: MNkImageSlider, for indexPath: IndexPath) -> SliderCell{
        let cell = slider.dequeSliderCell(with: "test", for: indexPath) as! SliderSample
        cell.label.text = "\(indexPath)"
        cell.imageData = data[indexPath.item]
        return cell
    }
    
    func mnkSliderSizeForItem(at indexPath: IndexPath, of collectionView: UICollectionView) -> CGSize {
        return CGSize.init(width: collectionView.bounds.size.width/2, height: collectionView.bounds.size.height)
    }
    
    func mnkSliderScrolled(toSlider indexPath: IndexPath, of cell: SliderCell?) {
       print("Scrolled: ",indexPath.item)
    }
    func mnkSliderDidSelectSlider(item: Any, _ cell: SliderCell, at indexPath: IndexPath) {
        imageSliderStoryBoard.isAnimate = false
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
