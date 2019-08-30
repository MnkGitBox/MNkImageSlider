//
//  BackwardSliderLayout.swift
//  MNkImageSlider
//
//  Created by Malith Nadeeshan on 8/30/19.
//

import MNkSliderEffectCollectionViewLayout

class BackwardSliderLayout:MNkSliderScrollEffectLayout{
    
    override func configLayoutDefaultOp() {
        super.configLayoutDefaultOp()
        collectionView?.setContentOffset(initContentInsetForDisplayPosition(), animated: false)
    }
    
    public func initContentInsetForDisplayPosition()->CGPoint{
        guard let cv = collectionView else{return .zero}
        var offSet:CGPoint
        
        switch displayPosition{
        case .left:
            offSet = CGPoint.init(x: contentWidth - cellSize.width,
                                  y: cv.contentOffset.y)
        case .right:
            offSet = CGPoint.init(x: contentWidth - cv.bounds.size.width,
                                  y: cv.contentOffset.y)
        case .middle:
            offSet = CGPoint.init(x: contentWidth - (cv.bounds.size.width-((cv.bounds.size.width/2)-(cellSize.width/2))),
                                  y: cv.contentOffset.y)
        }
        return offSet
    }
}
