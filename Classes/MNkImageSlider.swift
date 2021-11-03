//
//  MNkImageSlider.swift
//
//  Created by Malith Nadeeshan on 2017-12-02.
//  Copyright © 2017 MNkApps. All rights reserved.
//

import MNkSliderEffectCollectionViewLayout
import UIKit

open class MNkImageSlider: UIView {
    public enum IndicatorAlignment{
        case center
        case left
        case right
        
        var positionFactor:CGFloat{
            switch self{
            case .center:
                return 0.5
            case .left:
                return 0
            case .right:
                return 1
            }
        }
    }
    
    /*....................................
     Mark:- Public configurable paramters
     .....................................*/
    public var sliderBackgroundColor:UIColor = .white{
        didSet{
            self.backgroundColor = sliderBackgroundColor
        }
    }

    public var delegate:MNkSliderDelegate?
    public var datasource:MNkSliderDataSource?

    public var indicatorMaxWidth:CGFloat = 100{didSet{calculateIndicatorRect()}}
    public var adjustIndicatorWidthAutomatically:Bool = true{didSet{calculateIndicatorRect()}}
    public var indicatorBottomPadding:CGFloat = 10{didSet{calculateIndicatorRect()}}
    public var indicatorAlign:IndicatorAlignment = .center{didSet{calculateIndicatorRect()}}
    public var isActiveIndicator:Bool{
        get{
            return !indicators.isHidden
        }set{
            indicators.isHidden = !newValue
        }
    }
    
    public var slideActivePosition:ActiveCellDisplayPosition = .left{
        didSet{
            layout.displayPosition = slideActivePosition
        }
    }
    
    @IBInspectable public var isRepeat:Bool = false{
        didSet{
            collectionView.reload()
        }
    }
    public var delay:Double = 1.0{
        didSet{
            animator.animationIntervals = delay
            guard isAnimate else{return}
            stopSlider()
            playSlider()
        }
    }
    public var repeatFactor:Int = 100{
        didSet{
            collectionView.reload()
        }
    }
    public var isAnimate:Bool = false{
        didSet{
            guard isAnimate else{
                stopSlider()
                return
            }
            playSlider()
        }
    }
    
    //MARK: - CUSTOM CAROUSEL LAYOUT CONFIG PULIC VAR
    ///Space between two carousel cell
    public var interItemSpace:CGFloat = 0{
        didSet{
            layout.interItemSpace = interItemSpace
        }
    }
    ///Minimum scale factor carousel will display
    public var minScaleFactor:CGFloat = 1.0{
        didSet{
            layout.minScaleFactor = minScaleFactor
        }
    }
    ///Minimum alpha factor for carousel cell
    public var minAphaFactor:CGFloat = 1.0{
        didSet{
            layout.minAlphaFactor = minAphaFactor
        }
    }
    ///Carousel cell active position. Active cell will display in actual size and alpha of 1.
    public var activePosition:ActiveCellDisplayPosition = .left{
        didSet{
            layout.displayPosition = activePosition
        }
    }
    ///Enable paging for carousel cells.
    public var carouselPaginEnabled:Bool = true{
        didSet{
            layout.isPaginEnabled = carouselPaginEnabled
        }
    }
    
    ///Enable paging for default slider
    public var isPagingEnabled:Bool = false{
        didSet{
            collectionView.isPagingEnabled = isPagingEnabled
        }
    }
    
    /*...................
     Mark:- public views
     ....................*/
    public var indicators:ItemIndicators!
    
    /*....................................
     Mark:- private  parameters
     .....................................*/
    private var sliderCell:String{
        return "sliderCell"
    }
    var collectionView:UICollectionView!
    public var layout:MNkSliderScrollEffectLayout!
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
        layout.interItemSpace = interItemSpace
        layout.minScaleFactor = minScaleFactor
        layout.displayPosition = activePosition
        layout.isPaginEnabled = carouselPaginEnabled
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.sliderScrollEffectDelegate = self
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        indicators = ItemIndicators()
        indicators.datasouce = self
        
        animator = SliderAnimator()
        animator.slider = self
        animator.direction = sliderDirection
        animator.animationIntervals = delay
    }
    
    private func insertAndLayoutViews(){
        addSubview(collectionView)
        addSubview(indicators)
        
        NSLayoutConstraint.activate([collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                                     collectionView.topAnchor.constraint(equalTo: self.topAnchor),
                                     collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
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
    
    
    
    public init(frame:CGRect = .zero,_ direction:SliderDirection = .forward) {
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
    

    open override func layoutSubviews() {
        super.layoutSubviews()
        calculateIndicatorRect()
    }
    
    /*.........................................
     Mark:- Animation controll func going here
     .........................................*/
    private func playSlider(){
        animator.start()
    }
    
    private func stopSlider(){
        animator.stop()
    }

    /*.........................................
     Mark:- Animation controll func going here
     .........................................*/
    public func reloadData(){
        calculateIndicatorRect()
        collectionView.reloadData()
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
 
    //MARK:- CALCULATE INIDICATOR POSITION AND SIZE ACORDING USER CONFIG
    private func calculateIndicatorRect(){
        guard isActiveIndicator,
        numberOfItems > 1
        else{
            indicators.alpha = 0
            return
        }
        indicators.alpha = 1
        
        let itemWidth = (CGFloat(numberOfItems)  * indicators.indicatorViewSize) + (CGFloat(numberOfItems - 1) * indicators.indicatorSpace)
        let width = ((adjustIndicatorWidthAutomatically && (itemWidth < indicatorMaxWidth)) ? itemWidth : indicatorMaxWidth) + indicators.padding + indicators.padding
        let height = indicators.indicatorViewSize + indicators.padding + indicators.padding
        let originX = (self.bounds.width - width) * indicatorAlign.positionFactor
        let originY = self.bounds.height - (height+indicatorBottomPadding)
        indicators.frame = CGRect.init(origin: CGPoint.init(x: originX,
                                                           y: originY),
                                      size: CGSize.init(width: width,
                                                        height:height))
        indicators.reload()
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
        delegate?.mnkSliderDidSelectSlider(item: imageData, cell, at: indexPath)
    }
    
    public func sliderCollectionView(activeCell indexPath: IndexPath, in collectionView: UICollectionView, with layout: MNkSliderScrollEffectLayout) {
        //set selected indicator for carousel layout
        indicators.selectedIndex = indexPath.item
        //return selected index delegate
        let cell = collectionView.cellForItem(at:indexPath) as? SliderCell
        delegate?.mnkSliderScrolled(toSlider: itemIndex(for: indexPath), of: cell)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        layout.setDisplayCellForAnimated(offSet: scrollView.contentOffset)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.mnkSliderBegainDragging()
        guard isAnimate else{return}
        stopSlider()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.mnkSliderEndDragging()
        guard isAnimate else{return}
        playSlider()
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        guard isAnimate else{return}
        stopSlider()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard isAnimate else{return}
        playSlider()
    }
  
}

//MARK: - INDICATOR DATASOURCE IMPLIMENTATION
extension MNkImageSlider:ItemIndicatorDatasouce{
    func numberOfItemsForIndicator() -> Int {
        return numberOfItems
    }
}
