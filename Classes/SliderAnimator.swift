//
//  SliderAnimator.swift
//  MNkImageSlider
//
//  Created by Malith Nadeeshan on 8/29/19.
//

import Foundation

class SliderAnimator:NSObject{
    var slider:MNkImageSlider!
    
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
        
        let isFinalIndex = currIndexPath.item >= (numberOfSliders-1)
        let indexPath = isFinalIndex ? IndexPath.init(item: 0, section: 0) : currIndexPath
        let isAnimated = isFinalIndex ? false : true
        guard let layoutAttrib = slider.layout.layoutAttributesForItem(at: indexPath) else{
            stop()
            return
        }
        
        let newOffSet = isFinalIndex ? .zero : CGPoint.init(x: (cv.contentOffset.x + layoutAttrib.size.width + (slider.layout.interItemSpace)),
                                                    y: cv.contentOffset.y)

        print(isFinalIndex,newOffSet,indexPath)
        
        cv.setContentOffset(newOffSet, animated: isAnimated)
    }
}
