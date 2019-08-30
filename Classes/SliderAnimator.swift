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
    
    func start(fromSlide indexPath:IndexPath){
        guard numberOfSliders > 0 else{return}
        DispatchQueue.main.asyncAfter(deadline: .now() + animationIntervals) {
            self.timer = Timer.scheduledTimer(timeInterval: self.animationIntervals,
                                         target: self,
                                         selector: #selector(self.setAnimation(_:)),
                                         userInfo: nil,
                                         repeats: true)
        }
       
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
        
        let indexPath = slider.layout.pagingPoint(for: cv.contentOffset).activeIndexPath
        let initContentInsetLeft = slider.layout.contentInset(forDisplay: slider.layout.displayPosition).left
        let isFinalIndex = indexPath.item >= (numberOfSliders-1)
        let isAnimated = isFinalIndex ? false : true
        guard let layoutAttrib = slider.layout.layoutAttributesForItem(at: indexPath) else{
            stop()
            return
        }
       
        let point = CGPoint.init(x: -initContentInsetLeft, y: cv.contentOffset.y)
        let newOffSet = isFinalIndex ?  point : CGPoint.init(x: (cv.contentOffset.x + layoutAttrib.size.width + (slider.layout.interItemSpace)),
                                                            y: cv.contentOffset.y)
        
        
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
        
        let newOffSet = isFinalIndex ? initContentOffSet : CGPoint.init(x: (cv.contentOffset.x - layoutAttrib.size.width - (slider.layout.interItemSpace)),
                                                            y: cv.contentOffset.y)
     
        cv.setContentOffset(newOffSet, animated: isAnimated)
        
        if isFinalIndex{
            slider.layout.setDisplayCellForAnimated(offSet: cv.contentOffset)
        }
    }
}
