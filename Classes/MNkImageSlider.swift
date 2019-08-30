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
    
    public var delay:Double = 5.0{
        didSet{
            animator.animationIntervals = delay
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
    
    public var slideActivePosition:ActiveCellDisplayPosition = .left{
        didSet{
            layout.displayPosition = slideActivePosition
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

        layout = sliderDirection == .forward ?  MNkSliderScrollEffectLayout() : BackwardSliderLayout()
        layout.interItemSpace = 0
        layout.minScaleFactor = 0.8
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
        animator.direction = sliderDirection
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
        animator.start(fromSlide: IndexPath.init(row: 0, section: 0))
    }
    
    public func stopSlider(){
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

    /*..................................................................................
     Mark:- Get item index acording to current indexPath
     This for looping sliders countinuesly when user scroll view slider right or left.
     ...................................................................................*/
    public func itemIndex(for indexPath:IndexPath)->IndexPath{
        guard isRepeat else{return indexPath}
        let itemsLoopTimes = CGFloat(indexPath.item / numberOfItems).rounded(.down)
        let itemsLoopedUnion = CGFloat(numberOfItems) * itemsLoopTimes
        var indexItem = Int(CGFloat(indexPath.item) - itemsLoopedUnion)
        
        if sliderDirection == .backward{
            indexItem = (numberOfItems-1) - indexItem
        }
        
        return IndexPath(item: indexItem, section: indexPath.section)
    }
    
    public func dequeSliderCell(with identifier:String,for indexPath:IndexPath)->SliderCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? SliderCell else{fatalError("could not dequeue a view of kind: SliderCell with identifier \(identifier) - must register class for the identifier using slider. register(slider view:AnyClass?,with identifier:String")}
        return cell
    }
    
    var activeIndex:IndexPath?
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
        delegate?.mnkSliderDidSelectSlider(item: imageData, cell, at: indexPath)
    }
    
    public func sliderCollectionView(activeCell indexPath: IndexPath, in collectionView: UICollectionView, with layout: MNkSliderScrollEffectLayout) {
        let cell = collectionView.cellForItem(at:indexPath) as? SliderCell
        delegate?.mnkSliderScrolled(toSlider: itemIndex(for: indexPath), of: cell)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        layout.setDisplayCellForAnimated(offSet: scrollView.contentOffset)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("Stop")
        stopSlider()
        delegate?.mnkSliderBegainDragging()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("Start")
        playSlider()
        delegate?.mnkSliderEndDragging()
    }
  
}
