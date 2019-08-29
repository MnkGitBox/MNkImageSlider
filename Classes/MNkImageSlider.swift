//
//  MNkImageSlider.swift
//
//  Created by Malith Nadeeshan on 2017-12-02.
//  Copyright © 2017 MNkApps. All rights reserved.
//

import MNkSliderEffectCollectionViewLayout
import UIKit

open class MNkImageSlider: UIView {
    
    /*....................................
     Mark:- Public configurable paramters
     .....................................*/
    public var sliderBackgroundColor:UIColor = .white{
        didSet{
            self.backgroundColor = sliderBackgroundColor
        }
    }
    
    //TODO:- need to set slider indicator inside scrollview and change this as uiedge inserts
    public var indicatorBottomInsets:CGFloat = -8{
        didSet{
            indicatorBottomConstant?.constant = indicatorBottomInsets
            layoutIfNeeded()
        }
    }

    public var delegate:MNkSliderDelegate?
    public var datasource:MNkSliderDataSource?

    @IBInspectable public var isRepeat:Bool = false
    
    public var delay = TimeInterval(5){
        didSet{
            guard isAnimating else{return}
            stopSlider()
            playSlider()
        }
    }
    
    public var sliderSize:Sizes = .full{
        didSet{
            collectionView.reload()
        }
    }
    
    public var isActiveIndicator:Bool{
        get{
            return !indicator.isHidden
        }set{
            indicator.isHidden = !newValue
        }
    }
    
    public var repeatFactor:Int = 100{
        didSet{
            collectionView.reload()
        }
    }
    
    
    /*...................
     Mark:- public views
     ....................*/
    public var indicator:ItemIndicators!
    
    /*....................................
     Mark:- private  parameters
     .....................................*/
    private var sliderCell:String{
        return "sliderCell"
    }
    var collectionView:UICollectionView!
    
    var layout:MNkSliderScrollEffectLayout!
    
    private var currImgIndex:Int = 0
    
    private var indicatorBottomConstant:NSLayoutConstraint?
    
    private var isAnimating:Bool = false
    
    private var isUserStartAnimating:Bool = false
    
    private var timer:Timer?
    
    private var sliderDirection:SliderDirection = .forward
    
    private var animator:SliderAnimator!
    
    private var numberOfItems:Int{
        guard let items = datasource?.mnkSliderNumberOfItems(in: self) else{
            return 0
        }
        return items
    }
    
    
    
    
    /*.......................................
     Mark:- Create layout and configure views
     .......................................*/
    private func createViews(){

        layout = MNkSliderScrollEffectLayout()
        layout.interItemSpace = 0
        layout.minScaleFactor = 1.0
        layout.displayPosition = .middle
        layout.isPaginEnabled = true
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.sliderScrollEffectDelegate = self
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        indicator = ItemIndicators(numberOfItems)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        animator = SliderAnimator()
        animator.slider = self
    }
    
    private func insertAndLayoutViews(){
        addSubview(collectionView)
        addSubview(indicator)
        
        NSLayoutConstraint.activate([collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                                     collectionView.topAnchor.constraint(equalTo: self.topAnchor),
                                     collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
        
        indicatorBottomConstant = indicator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: indicatorBottomInsets)
        indicatorBottomConstant?.isActive = true
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: centerXAnchor)])
    }
    private func config(){
        collectionView.register(SliderCell.self, forCellWithReuseIdentifier: sliderCell)
        collectionView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    
    /*....................................
     Mark:- Register custom cell to Slider
     .....................................*/
    public func register(slider cell:AnyClass?,with identifier:String){
        collectionView.register(cell.self, forCellWithReuseIdentifier: identifier)
    }
    
    
    
    public init(frame:CGRect = .zero,_ direction:SliderDirection = .forward,_ size:Sizes = .full) {
        self.sliderSize = size
        self.sliderDirection = direction
        super.init(frame: frame)
        createViews()
        insertAndLayoutViews()
        config()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        createViews()
        insertAndLayoutViews()
        config()
    }
    

    /*.........................................
     Mark:- Animation controll func going here
     .........................................*/
    public func playSlider(){
        isUserStartAnimating = true
        animator.start(fromSlide: IndexPath.init(row: 0, section: 0))
    }
    
    public func stopSlider(){
        guard isAnimating else{return}
        animator.stop()
    }

    /*.........................................
     Mark:- Animation controll func going here
     .........................................*/
    public func reloadData(){
        collectionView.reload()
        
        guard isActiveIndicator else{return}
        indicator.items = numberOfItems
        indicator.activeIndex = currImgIndex
    }

    private func selectedItemIndex(using currentIndexPath:IndexPath)->Int{
        let currScrollIndex = CGFloat(currentIndexPath.item)
        let itemIndex = currScrollIndex.truncatingRemainder(dividingBy: CGFloat(numberOfItems))
        guard sliderDirection == .backward else{return Int(itemIndex)}
        let backWardIndex = (numberOfItems - 1) - Int(itemIndex)
        return backWardIndex
    }
    /*..................................................................................
     Mark:- Get item index acording to current indexPath
     This for looping sliders countinuesly when user scroll view slider right or left.
     ...................................................................................*/
    public func itemIndex(for indexPath:IndexPath)->IndexPath{
        guard isRepeat else{return indexPath}
        let itemsLoopTimes = CGFloat(indexPath.item / numberOfItems).rounded(.down)
        let itemsLoopedUnion = CGFloat(numberOfItems) * itemsLoopTimes
        let indexItem = Int(CGFloat(indexPath.item) - itemsLoopedUnion)
        return IndexPath(item: indexItem, section: indexPath.section)
    }
    
    public func dequeSliderCell(with identifier:String,for indexPath:IndexPath)->SliderCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? SliderCell else{fatalError("could not dequeue a view of kind: SliderCell with identifier \(identifier) - must register class for the identifier using slider. register(slider view:AnyClass?,with identifier:String")}
        return cell
    }
}

/*...................................................
 Mark:- Collectionview delegate and datasource impli.
 ....................................................*/
extension MNkImageSlider:UICollectionViewDataSource,MNkSliderScrollEffectLayoutProtocol,UICollectionViewDelegate{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !isRepeat else{
            return numberOfItems * repeatFactor
        }
        return numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemIndexPath = itemIndex(for: indexPath)
        let cell = datasource!.mnkSliderItemCell(in: self, for: itemIndexPath)
        return cell
    }

    public func collectionview(_ collectionView: UICollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let delegateSize = delegate?.mnkSliderSizeForItem(at: indexPath, of: collectionView) else{
            return collectionView.bounds.size
        }
        return delegateSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at:indexPath) as? SliderCell,
            let imageData = cell.imageData else{return}
        delegate?.didSelectSlider(item: imageData, cell, at: itemIndex(for: indexPath))
    }
    
    public func sliderCollectionView(activeCell indexPath: IndexPath, in collectionView: UICollectionView, with layout: MNkSliderScrollEffectLayout) {
        let selectedItemIndex = self.selectedItemIndex(using: indexPath)
        delegate?.sliderScrolledPage(selectedItemIndex)
    }
    
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        layout.setDisplayCellForAnimated(offSet: scrollView.contentOffset)
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.x == layout.interItemSpace else{return}
        layout.setDisplayCellForAnimated(offSet: scrollView.contentOffset)
    }
  
}
