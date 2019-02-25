//
//  Slider.swift
//  MNkImageSlider
//
//  Created by MNk_Dev on 25/2/19.
//

import UIKit

protocol SliderDataSource{
    func itemsForSlider()->[Any]
}

protocol SliderDelegate{
    func sliderBegainDragging()
    func sliderEndDragging()
    func sliderScrolledPage(_ pageIndex:Int)
}

public class Slider:UIView{
    
    
    /*....................................
     Mark:- Public configurable veriables
     .....................................*/
    public var insets:UIEdgeInsets = .zero{
        didSet{
            reloadData()
        }
    }
    public var imageContentMode:UIViewContentMode = .scaleToFill{
        didSet{
            reloadData()
        }
    }
    public var placeHolder:UIImage?
    
    
    
    
    
    
    
    
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
    
    
    private let sliderCell = "sliderCell"
    
    
    
    /*.......................
     Mark:- internal views
     ........................*/
    var collectionView:UICollectionView!
    
    
    
    
    
    
    /*.......................
     Mark:- Private variables
     ........................*/
    private var items:[Any]{
        return dataSource?.itemsForSlider() ?? []
    }
    private var isAnimating:Bool = false
    
    private var itemWidth:CGFloat{
        return collectionView.bounds.size.width + flowLayout.minimumInteritemSpacing
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
    
    var isLastItem:Bool{
        return nextContentOffSetX == 0.0
    }
    private var flowLayout:UICollectionViewFlowLayout{
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    private var nextContentOffSetX:CGFloat{
        let remain = contentOffSetX.truncatingRemainder(dividingBy: itemWidth)
        let nextCoOffSet = (contentOffSetX - remain) + itemWidth
        guard nextCoOffSet < itemsWidth else {
            return 0.0
        }
        return nextCoOffSet
    }
    
    
    

    
    
    
    /*........................................
     Mark:- Create and layout and config views
     .........................................*/
    private func createViews(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        
    }
    private func inserAndLayoutSubviews(){
        addSubview(collectionView)
        NSLayoutConstraint.activate([collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     collectionView.topAnchor.constraint(equalTo: topAnchor),
                                     collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)])
    }
    
    private func config(){
        collectionView.register(SliderCVCell.self, forCellWithReuseIdentifier: sliderCell)
        collectionView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    init(_ placeHolder:UIImage?) {
        self.placeHolder = placeHolder
        super.init(frame: .zero)
        createViews()
        inserAndLayoutSubviews()
        config()
    }
    
    required  public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData(){
        collectionView.reloadData()
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
    private func setSelectedPage(inScrollPositionOf scrollView:UIScrollView){
        let index = selectedItemIndex(in: scrollView)
        delegate?.sliderScrolledPage(index)
    }
    
    private func selectedItemIndex(in scrollView:UIScrollView)->Int{
        let currScrollIndex = CGFloat(contentOffSetX / itemWidth)
        let itemIndex = currScrollIndex.truncatingRemainder(dividingBy: CGFloat(items.count))
        return Int(itemIndex)
    }
    
    
    /*..................................................................................
     Mark:- Get item index acording to current indexPath
     This for looping sliders countinuesly when user scroll view slider right or left.
     ...................................................................................*/
    private func itemIndex(for indexPath:IndexPath)->Int{
        guard isRepeat else{return indexPath.item}
        let itemsLoopTimes = CGFloat(indexPath.item / items.count).rounded(.down)
        let itemsLoopedUnion = CGFloat(items.count) * itemsLoopTimes
        let indexItem = Int(CGFloat(indexPath.item) - itemsLoopedUnion)
        return indexItem
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
        setSelectedPage(inScrollPositionOf: scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setSelectedPage(inScrollPositionOf: scrollView)
    }
 
}















/*...................................................
 Mark:- Collectionview delegate and datasource impli.
 ....................................................*/
extension Slider:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !isRepeat else{
            return items.count * 100
        }
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sliderCell, for: indexPath) as! SliderCVCell
        cell.imageData = items[itemIndex(for: indexPath)]
                cell.sliderInset = insets
                cell.imageContentMode = imageContentMode
                cell.placeHolder = placeHolder
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.size
        return size
    }
    
}
