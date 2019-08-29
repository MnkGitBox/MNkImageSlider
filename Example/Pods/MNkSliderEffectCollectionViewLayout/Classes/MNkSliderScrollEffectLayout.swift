//
//  SliderScrollEffectLayout.swift
//  MNkSliderAnimator
//
//  Created by Malith Nadeeshan on 8/26/19.
//  Copyright © 2019 MNk. All rights reserved.
//

import UIKit


public protocol MNkSliderScrollEffectLayoutProtocol{
    func collectionview(_ collectionView:UICollectionView,sizeForItemAt indexPath:IndexPath)->CGSize
    func sliderCollectionViewAnimator(for collectionView:UICollectionView,with layout:MNkSliderScrollEffectLayout)->SliderAnimator
    func sliderCollectionView(activeCell indexPath:IndexPath,in collectionView:UICollectionView,with layout:MNkSliderScrollEffectLayout)
}

public extension MNkSliderScrollEffectLayoutProtocol{
    func collectionview(_ collectionView:UICollectionView,sizeForItemAt indexPath:IndexPath)->CGSize{
        return CGSize.init(width: 50, height: 50)
    }
    func sliderCollectionViewAnimator(for collectionView:UICollectionView,with layout:MNkSliderScrollEffectLayout)->SliderAnimator{
        return SliderAnimator()
    }
    func sliderCollectionView(activeCell indexPath:IndexPath,in collectionView:UICollectionView,with layout:MNkSliderScrollEffectLayout){}
}


open class MNkSliderScrollEffectLayout:UICollectionViewLayout{
    
    /*............................................................
     Mark:-You can publicly access this properties to make chnages.
     ...........................................................*/
    internal var delegate:MNkSliderScrollEffectLayoutProtocol?
    public var minScaleFactor:CGFloat = 0.8
    public var minAlphaFactor:CGFloat = 1.0
    public var isPaginEnabled:Bool = false{
        didSet{
            collectionView?.decelerationRate = isPaginEnabled ? .fast : .normal
        }
    }
    public var interItemSpace:CGFloat = 10
    public var displayPosition:ActiveCellDisplayPosition = .left{
        didSet{
            contentInset(forDisplay: displayPosition)
        }
    }
    public var cache = [UICollectionViewLayoutAttributes]()
    public var displayIndexPath:IndexPath{
        return _displayIndexPath
    }
    //
    private var _displayIndexPath = IndexPath.init(item: 0, section: 0){
        didSet{
            guard isPaginEnabled else{return}
            delegate?.sliderCollectionView(activeCell:_displayIndexPath,
                                           in: collectionView!,
                                           with: self)
        }
    }
    private var cellSize:CGSize = .init(width: 50, height: 50)
    private var contentWidth:CGFloat = 0
    
    
    override open var collectionViewContentSize: CGSize{
        guard let cv = collectionView else{return .zero}
        return CGSize.init(width: contentWidth, height: cv.bounds.size.height)
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func prepare() {
        guard cache.isEmpty,
            let cv = collectionView
            else{return}
        
        for item in 0..<cv.numberOfItems(inSection: 0){
            prepareLayotAttribute(for: item, 0, in: cv)
        }
        
        configLayoutDefaultOp()
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleAttribs = [UICollectionViewLayoutAttributes]()
        for attrib in cache{
            guard attrib.frame.intersects(rect) else{continue}
            visibleAttribs.append(attrib)
        }
        
        return animatorAttribute(for: visibleAttribs)
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let pagingPoint = self.pagingPoint(for: proposedContentOffset)
        _displayIndexPath = pagingPoint.activeIndexPath
        return pagingPoint.activeCellOffSetX
    }
    
    /*.......................................................................
     Mark:-Prepare Layout attribute for given item from datasourse protocol
     ............................................................................*/
    ///You can override this method to create Fucking any layout that you want.
    open func prepareLayotAttribute(for item:Int,_ section:Int,in cv:UICollectionView){
        let indexPath = IndexPath.init(item: item, section: 0)
        let atrib = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        if let _delegate = delegate{
            cellSize = _delegate.collectionview(cv, sizeForItemAt: indexPath)
        }
        
        let xOffSet = (cellSize.width * CGFloat(item)) + (interItemSpace*(CGFloat(item)+1))
        let yOffSet = (cv.bounds.size.height - cellSize.height)*0.5
        let cellOrigin = CGPoint.init(x:xOffSet, y: yOffSet)
        let cellFrame = CGRect.init(origin: cellOrigin,
                                    size:cellSize)
        
        atrib.frame = cellFrame
        cache.append(atrib)
        
        contentWidth = cellFrame.maxX
    }
    
    
    /*.......................................................................
     Mark:-Configuration for default layourt behaviour
     .......................................................................*/
    private func configLayoutDefaultOp(){
        contentInset(forDisplay: displayPosition)
        _displayIndexPath = activectiveIndexInReload()
    }
    
    
    /*.......................................................................
     Mark:- Return Active indexPath when reloading collection
     .......................................................................*/
    private func activectiveIndexInReload()->IndexPath{
        guard let finalAttrib = cache.last,
            let cv = collectionView
            else{return IndexPath.init(item: 0, section: 0)}
        
        let offSet = finalAttrib.indexPath.item < _displayIndexPath.item ? finalAttrib.frame.origin : cv.contentOffset
        
        return pagingPoint(for: offSet).activeIndexPath
    }
    
    
    /*.......................................................................
     Mark:- Generate animation attributes with user supplied animator object
     - User can hand over this type custom animator using delegate method.
     .......................................................................*/
    private func animatorAttribute(for visibleAttribs:[UICollectionViewLayoutAttributes])->[UICollectionViewLayoutAttributes]{
        guard let cv = collectionView,
            let animator = delegate?.sliderCollectionViewAnimator(for:cv,
                                                                  with: self)
            else{return visibleAttribs}
        
        animator.cellSize = cellSize
        animator.collectionView = cv
        animator.interItemSpace = interItemSpace
        animator.minScaleFactor = minScaleFactor
        animator.minAlphaFactor = minAlphaFactor
        
        return animator.animatorAttibutes(using: visibleAttribs,
                                          atDisplay: displayPosition)
    }
    
    
    /*..................................................................................
     Mark:- Set content inset value of collectionview acording to cell dispaly position.
     - Using this method, we can visible first once also last one as active cell at display point.
     .............................................................................................*/
    private func contentInset(forDisplay position:ActiveCellDisplayPosition){
        guard let cv = collectionView else{return}
        
        var inset:UIEdgeInsets
        
        switch position{
        case .left:
            inset =  UIEdgeInsets.init(top: 0,
                                     left: 0,
                                     bottom: 0,
                                     right: cv.bounds.size.width - (cellSize.width+interItemSpace))
        case .right:
            inset = UIEdgeInsets.init(top: 0,
                                     left: cv.bounds.size.width - (cellSize.width+(interItemSpace*2)),
                                     bottom: 0,
                                     right: interItemSpace)
        case .middle:
            let sidePadding = (cv.bounds.size.width / 2) - (cellSize.width/2)
            inset =  UIEdgeInsets.init(top: 0,
                                     left: sidePadding,
                                     bottom: 0,
                                     right: sidePadding)
        }
        cv.contentInset = inset
    }
    
}




/*.........................................................
 Mark:- Paging to active cell of slider collectionview.
 - This happen acording to display cell position.
 .........................................................*/
extension MNkSliderScrollEffectLayout{
    private func pagingPoint(for proposeOffSet:CGPoint)->(activeCellOffSetX:CGPoint,activeIndexPath:IndexPath){
        var activeIndexPath = IndexPath.init(item: 0, section: 0)
        guard let cv = collectionView,
            isPaginEnabled
            else{return (proposeOffSet,activeIndexPath)}
        
        
        let rect = pagingRect(for: cv, for: proposeOffSet)
        guard let attribe = layoutAttributesForElements(in: rect) else{return (proposeOffSet,activeIndexPath)}
        
        let maxClipAttrib = attribe.max{$0.frame.intersection(rect).width < $1.frame.intersection(rect).width}
        
        guard let _maxClipAttrib = maxClipAttrib else{return (proposeOffSet,activeIndexPath)}
        let maxCellPaginOffSet = pagingCellOffSetX(forMaxClipping: _maxClipAttrib,
                                                   forDisplay: displayPosition,
                                                   in: cv,
                                                   proposeOffSet)
        activeIndexPath = _maxClipAttrib.indexPath
        
        return (maxCellPaginOffSet,activeIndexPath)
    }
    
    private func pagingRect(for cv:UICollectionView,for proposeOffSet:CGPoint)->CGRect{
        let originY = (cv.bounds.size.height / 2)-(cellSize.width/2)
        let originX:CGFloat
        
        switch displayPosition{
        case .left:
            originX = proposeOffSet.x
        case .right:
            originX = proposeOffSet.x + (cv.bounds.size.width - cellSize.width)
        case .middle:
            originX = proposeOffSet.x + ((cv.bounds.size.width / 2) - (cellSize.width/2))
        }
        
        return CGRect.init(origin: CGPoint.init(x: originX,
                                                y: originY),
                           size: cellSize)
    }
    
    private func pagingCellOffSetX(forMaxClipping attrib:UICollectionViewLayoutAttributes,
                                   forDisplay position:ActiveCellDisplayPosition,
                                   in cv:UICollectionView,
                                   _ proposeOffSet:CGPoint)->CGPoint{
        let posY:CGFloat = proposeOffSet.y
        let posX:CGFloat
        
        switch displayPosition {
        case .left:
            posX = attrib.actualFrame.minX - interItemSpace
        case .right:
            posX = (attrib.actualFrame.maxX + interItemSpace)-cv.bounds.size.width
        case .middle:
            posX = attrib.center.x - (cv.bounds.size.width/2)
        }
        return CGPoint.init(x: posX, y: posY)
    }
    
    ///Set Display cell for animated content offSet
    public func setDisplayCellForAnimated(offSet point:CGPoint){
        _displayIndexPath = pagingPoint(for: point).activeIndexPath
    }
}
