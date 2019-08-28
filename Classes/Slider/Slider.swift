//
//  Slider.swift
//  MNkImageSlider
//
//  Created by Malith Nadeeshan on 25/2/19.
//

import UIKit
import MNkSliderEffectCollectionViewLayout

public protocol SliderDataSource{
    func itemsForSlider()->[Any]
}


public protocol MNkSliderDataSource{
    func mnkSliderItemCell(in slider:Slider,for indexPath:IndexPath)->SliderCell?
    func mnkSliderNumberOfItems(in slider:Slider)->Int
}

protocol SliderDelegate{
    func sliderBegainDragging()
    func sliderEndDragging()
    func sliderScrolledPage(_ pageIndex:Int)
    func didSelectSlider(item:Any,_ cell:SliderCell,at indexPath:IndexPath)
}

public class Slider:UIView{

    var direction:MNkImageSlider.SliderDirection = .forward

    /*................................
     Mark:- intrernal access veriables
     ..................................*/
    var isRepeat:Bool = false{
        didSet{
            collectionView.reloadData()
        }
    }
    
    var dataSource:SliderDataSource?
    var delegate:SliderDelegate?
    
    var sliderDataSource:MNkSliderDataSource?
    
    var size:MNkImageSlider.Sizes = .full{
        didSet{
            reloadData()
        }
    }
    
    var isLastItem:Bool{
        guard direction == .forward else{
            return nextContentOffSetX == lastContentOffSetForBackward
        }
        return nextContentOffSetX == 0.0
    }
    
    
    
    /*.......................
     Mark:- internal views
     ........................*/
    var collectionView:UICollectionView!
    var layout:MNkSliderScrollEffectLayout!
    
    
    
    
    
    
    /*.......................
     Mark:- Private variables
     ........................*/
    private let sliderCell = "sliderCell"
    
    private var slidetItems:[Any]{
        return dataSource?.itemsForSlider() ?? []
    }
    
    private var numberOfItems:Int{
        var items = 0
        if let _items = dataSource?.itemsForSlider().count{
            items = _items
        }
        if let _items = sliderDataSource?.mnkSliderNumberOfItems(in: self){
            items = _items
        }
        return items
    }
    
    private var isAnimating:Bool = false
    
    private var itemWidth:CGFloat{
        return sliderSizeForSizeClass(from: collectionView.bounds.size).width
    }
    
    private var contentOffSetY:CGFloat{
        return collectionView.contentOffset.y
    }
    
    private var contentOffSetX:CGFloat{
        return collectionView.contentOffset.x
    }
    
    private var itemsWidth:CGFloat{
        return collectionView.contentSize.width
    }
    
    private var directionAttrib:UISemanticContentAttribute{
        return self.direction == .forward ? UISemanticContentAttribute.forceLeftToRight : .forceRightToLeft
    }
    
    private var nextContentOffSetX:CGFloat{
        guard direction == .forward else{return contentOffSetForBackward()}
        return contentOffSetForForward()
    }
    
    private var lastContentOffSetForBackward:CGFloat{
        return collectionView.contentSize.width - collectionView.bounds.size.width
    }
    
    
    
    
    
    /*........................................
     Mark:- Create and layout and config views
     .........................................*/
    private func createViews(){
        layout = MNkSliderScrollEffectLayout()
        layout.interItemSpace = 0
        layout.minScaleFactor = 1.0
        layout.isPaginEnabled = true
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.sliderScrollEffectDelegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.semanticContentAttribute = directionAttrib
        
    }
    private func inserAndLayoutSubviews(){
        addSubview(collectionView)
        NSLayoutConstraint.activate([collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     collectionView.topAnchor.constraint(equalTo: topAnchor),
                                     collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)])
    }
    
    private func config(){
        collectionView.register(SliderCell.self, forCellWithReuseIdentifier: sliderCell)
        collectionView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    init(_ direction:MNkImageSlider.SliderDirection,_ size:MNkImageSlider.Sizes) {
        self.size = size
        self.direction = direction
        super.init(frame: .zero)
        createViews()
        inserAndLayoutSubviews()
        config()
    }
    
    required  public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    /*....................................
     Mark:- Register custom cell to Slider
     .....................................*/
    public func register(slider cell:AnyClass?,with identifier:String){
        collectionView.register(cell.self, forCellWithReuseIdentifier: identifier)
    }
    
    
    
    
    
    
    
    func reloadData(){
        collectionView.reload()
    }
    
    
    /*...............................................................
     Mark:- ContentOffSetX value for when layout backward and forward
     ...............................................................*/
    private func contentOffSetForForward()->CGFloat{
        let remain = contentOffSetX.truncatingRemainder(dividingBy: itemWidth)
        let nextCoOffSet = (contentOffSetX - remain) + itemWidth
        guard nextCoOffSet < itemsWidth else {
            return 0.0
        }
        return nextCoOffSet
    }
    
    private func contentOffSetForBackward()->CGFloat{
        let remain = contentOffSetX.truncatingRemainder(dividingBy: itemWidth)
        let nextCoOffSet = (contentOffSetX + remain) - itemWidth
        guard nextCoOffSet > 0.0 else {
            return lastContentOffSetForBackward
        }
        return nextCoOffSet
    }
    
    
    
    
    
    
    /*...................................
     Mark:- Slider cell animation impli.
     ....................................*/
    
    func animateSlider(){
        let isAnimate = isLastItem ? false : true
        collectionView.setContentOffset(CGPoint(x: nextContentOffSetX, y: contentOffSetY), animated: isAnimate)
    }
    
    
    /*...................................
     Mark:- Calculate selected page index
     ....................................*/
//    private func setSelectedPage(inScrollPositionOf scrollView:UIScrollView){
//        let index = selectedItemIndex(in: scrollView)
//        delegate?.sliderScrolledPage(index)
//    }
//
    private func selectedItemIndex(using currentIndexPath:IndexPath)->Int{
        let currScrollIndex = CGFloat(currentIndexPath.item)
        let itemIndex = currScrollIndex.truncatingRemainder(dividingBy: CGFloat(numberOfItems))
        guard direction == .backward else{return Int(itemIndex)}
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
    
    
    
    /*...........................................
     Mark:- Calculate size acording to size class
     ............................................*/
    private func sliderSizeForSizeClass(from size:CGSize)->CGSize{
        let sizeClass = self.size
        let devider = CGFloat(sizeClass.rawValue)
        let width = size.width / devider
        let _size = CGSize(width: width, height: size.height)
        return _size
    }
    
}
















/*...................................
 Mark:- Scrollview delegate impli.
 ....................................*/
extension Slider:UIScrollViewDelegate{
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.sliderBegainDragging()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else{return}
        delegate?.sliderEndDragging()
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.sliderEndDragging()
    }
}















/*...................................................
 Mark:- Collectionview delegate and datasource impli.
 ....................................................*/
extension Slider:UICollectionViewDataSource,MNkSliderScrollEffectLayoutProtocol,UICollectionViewDelegate{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !isRepeat else{
            return numberOfItems * 100
        }
        return numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell:SliderCell!
        
        let itemIndexPath = itemIndex(for: indexPath)
        
        if let _cell = sliderDataSource?.mnkSliderItemCell(in: self, for: itemIndexPath){
            cell = _cell
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: sliderCell, for: indexPath) as? SliderCell
            //            cell.placeHolder = placeHolder
            cell.imageData = slidetItems[itemIndexPath.item]
        }
        
        //        cell.sliderInset = insets
        //        cell.imageContentMode = imageContentMode
        return cell
    }
    
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let size = sliderSizeForSizeClass(from: collectionView.bounds.size)
//        return size
//    }
//
    public func collectionview(_ collectionView: UICollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderSizeForSizeClass(from: collectionView.bounds.size)
        print("Size :",size,"full Size: ",collectionView.bounds.size)
        return size
    }
    
    public func dequeSliderCell(with identifier:String,for indexPath:IndexPath)->SliderCell{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? SliderCell else{fatalError("could not dequeue a view of kind: SliderCell with identifier \(identifier) - must register class for the identifier using slider. register(slider view:AnyClass?,with identifier:String")}
        return cell
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
    
}



