//
//  Utilities.swift
//  MNkSliderAnimator
//
//  Created by Malith Nadeeshan on 8/26/19.
//  Copyright © 2019 MNk. All rights reserved.
//

import UIKit

public extension CGRect{
    var center:CGPoint{
        return CGPoint.init(x: self.minX + (self.width/2),
                            y: self.minY + (self.height/2))
    }
}

public extension UICollectionView{
    func cellPosition(ofCell attrib:UICollectionViewLayoutAttributes)->CGRect{
        return self.convert(attrib.frame, to: self.superview)
    }
    
    func reload(){
        guard let layout = self.collectionViewLayout as? MNkSliderScrollEffectLayout else{return}
        layout.cache = []
        self.reloadData()
        layout.invalidateLayout()
    }
    
    var sliderScrollEffectDelegate:MNkSliderScrollEffectLayoutProtocol?{
        get{
            return (collectionViewLayout as? MNkSliderScrollEffectLayout)?.delegate
        }
        set{
            (collectionViewLayout as? MNkSliderScrollEffectLayout)?.delegate = newValue
        }
    }
}

public protocol ActualFrame{
    var bounds:CGRect{get}
    var center:CGPoint{get}
}

extension UIView:ActualFrame{}

extension UICollectionViewLayoutAttributes:ActualFrame{}

public extension ActualFrame{
    var actualFrame:CGRect{
        let size = self.bounds.size
        let oX = center.x - (size.width / 2)
        let oY = center.y - (size.height / 2)
        let origin = CGPoint.init(x: oX, y: oY)
        return CGRect.init(origin: origin, size: size)
    }
}
