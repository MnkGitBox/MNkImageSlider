//
//  SliderAnimator.swift
//  MNkImageSlider
//
//  Created by Malith Nadeeshan on 8/29/19.
//

import Foundation

class SliderAnimator:NSObject{
    var slider:MNkImageSlider!
    var direction:SliderDirection = .forward
    
    var animationIntervals:Double = 2.0
    var isAnimating:Bool = false
    
    private var timer:Timer?
    private var currIndexPath:IndexPath{
        return slider.layout.displayIndexPath
    }
    private var numberOfSliders:Int{
        return slider.layout.collectionView?.numberOfItems(inSection: 0) ?? 0
    }
    private var cv:UICollectionView{
        return slider.collectionView
    }
    
    func start(){
        guard numberOfSliders > 0 else{return}
        timer = Timer.scheduledTimer(timeInterval: animationIntervals,
                                     target: self,
                                     selector: #selector(setAnimation(_:)),
                                     userInfo: nil,
                                     repeats: true)
        timer?.tolerance = (animationIntervals/100)*10
        RunLoop.current.add(timer!, forMode: .commonModes)
    }
    
    func stop(){
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func setAnimation(_ info:Timer){
        switch direction{
        case .forward:
            animateForward()
        case .backward:
            animateBackward()
        }
    }
    
    private func animateForward(){
        
        let pagingPoint = slider.layout.pagingPoint(for: cv.contentOffset)
        let indexPath = pagingPoint.activeIndexPath
        let initContentInsetLeft = slider.layout.contentInset(forDisplay: slider.layout.displayPosition).left
        let isFinalIndex = indexPath.item >= (numberOfSliders-1)
        let isAnimated = isFinalIndex ? false : true
        guard let layoutAttrib = slider.layout.layoutAttributesForItem(at: indexPath) else{
            stop()
            return
        }
       
        let initialOffSet = CGPoint.init(x: -initContentInsetLeft, y: cv.contentOffset.y)
        let nextSliderOffSet = CGPoint.init(x: pagingPoint.activeCellOffSetX.x+layoutAttrib.size.width,
                                            y: pagingPoint.activeCellOffSetX.y)
       
        let newOffSet = isFinalIndex ?  initialOffSet : nextSliderOffSet
        
        cv.setContentOffset(newOffSet, animated: isAnimated)
        
        if isFinalIndex{
            slider.layout.setDisplayCellForAnimated(offSet: cv.contentOffset)
        }
    }
    
    private func animateBackward(){
        guard let layout = slider.layout as? BackwardSliderLayout else{
            stop()
            return
        }
        let initContentOffSet = layout.initContentInsetForDisplayPosition()
        let indexPath = slider.layout.pagingPoint(for: cv.contentOffset).activeIndexPath
        let isFinalIndex = indexPath.item <= 0
        let isAnimated = isFinalIndex ? false : true
        
        guard let layoutAttrib = slider.layout.layoutAttributesForItem(at: indexPath) else{
            stop()
            return
        }
        
        let pagingPoint = slider.layout.pagingPoint(for: cv.contentOffset)
        let nextSliderOffSet = CGPoint.init(x: pagingPoint.activeCellOffSetX.x-layoutAttrib.size.width,
                                            y: pagingPoint.activeCellOffSetX.y)
        
        let newOffSet = isFinalIndex ? initContentOffSet : nextSliderOffSet
     
        cv.setContentOffset(newOffSet, animated: isAnimated)
        
        if isFinalIndex{
            slider.layout.setDisplayCellForAnimated(offSet: cv.contentOffset)
        }
    }
}
