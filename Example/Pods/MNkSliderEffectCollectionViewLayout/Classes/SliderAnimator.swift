//
//  SliderAnimator.swift
//  MNkSliderAnimator
//
//  Created by Malith Nadeeshan on 8/26/19.
//  Copyright © 2019 MNk. All rights reserved.
//

import UIKit

public class SliderAnimator:NSObject{
    
    internal var cellSize:CGSize!
    internal var collectionView:UICollectionView!
    internal var interItemSpace:CGFloat!
    internal var minScaleFactor:CGFloat!
    internal var minAlphaFactor:CGFloat!
    
    /*.......................................................
     Mark:- Calculate Cell active display point in screen.
     - Activate cell will center to this point.
     .......................................................*/
    private func displayPointX(forDisplay position:ActiveCellDisplayPosition)->CGFloat{
        switch position{
        case .left:
            return CGPoint.init(x: (cellSize.width / 2) + interItemSpace, y: 0).x
        case .right:
            return (collectionView.bounds.size.width - (cellSize.width / 2))
        case .middle:
            return collectionView.center.x
        }
    }
    
    
    /*................................................................................
     Mark:- Animator start animate end of this region.
     - And finish animation to identity state of start of this region(displayPointX)
     ....................................................................................*/
    private func animateRegionWidth(forDisplay position:ActiveCellDisplayPosition)->CGFloat{
        switch position{
        case .left,.right:
            return (collectionView.bounds.width - displayPointX(forDisplay: position)) + (cellSize.width/2)
        case .middle:
            return (collectionView.center.x + (cellSize.width/2))
        }
    }
    
    
    /*................................................................................
     Mark:- Current Attrib animation position of animation region(animateRegionWidth).
     ....................................................................................*/
    private func animatingPositionCenterX(of attrib:UICollectionViewLayoutAttributes,toDisplay position:ActiveCellDisplayPosition)->CGFloat{
        switch position{
        case .left,.middle:
            return collectionView.cellPosition(ofCell: attrib).center.x - displayPointX(forDisplay: position)
        case .right:
            return displayPointX(forDisplay: position) - collectionView.cellPosition(ofCell: attrib).center.x
        }
    }
    
    
    /*................................................................................
     Mark:- Current Attrib animation completed precentage in region(animateRegionWidth).
     - This will calculate what precentage Attrib remain to display point.
     ....................................................................................*/
    ///Given attribute animation precentage to display point.
    public func animatedPrecentage(of attrib:UICollectionViewLayoutAttributes,toDisplay position:ActiveCellDisplayPosition)->CGFloat{
        return 1.0 - (animatingPositionCenterX(of: attrib,
                                               toDisplay: position) / animateRegionWidth(forDisplay: position))
    }
    
    
    /*................................................................................
     Mark:- Calaculate the precentage factor acording to given min display factors.
     - Display factor tell us what precentage we want to keep as it.
     - We calculate final factor from remain precentage that can change.
     ....................................................................................*/
    ///Final precentage factor acording to given min display factor.
    public func displayFactor(for animatedPrecentage:CGFloat,with minDisplayFactor:CGFloat)->CGFloat{
        return ((1.0 - minDisplayFactor) * animatedPrecentage) + minDisplayFactor
    }
    
    /*...................................................................................................
     Mark:- Calaculate animation attributes to animation what we need.
     - We can take given attribute and calculate those position and scale to current animated precentage.
     - You can override this function and create animation attribute what you want and return
     ....................................................................................................*/
    ///Create animation attruibutes for animated precentage for display position.
    open func animatorAttibutes(using attribs:[UICollectionViewLayoutAttributes],
                                atDisplay position:ActiveCellDisplayPosition)->[UICollectionViewLayoutAttributes]{
        
        for var attrib in attribs{
            attrib = animatorAttribute(using: attrib,
                                       atDisplay: position)
        }
        
        return attribs
    }
    ///Create animation attruibute for animated precentage for display position.
    open func animatorAttribute(using attrib:UICollectionViewLayoutAttributes,
                                atDisplay position:ActiveCellDisplayPosition)->UICollectionViewLayoutAttributes{
        var _animatedPrecentage = animatedPrecentage(of:attrib, toDisplay: position)
        if _animatedPrecentage > 1.0{
            _animatedPrecentage = 1 - (_animatedPrecentage - 1)
        }
        
        let scaledFactor = self.displayFactor(for: _animatedPrecentage,with:minScaleFactor)
        let alphaFactor = self.displayFactor(for: _animatedPrecentage, with: minAlphaFactor)
        attrib.transform = .identity
        attrib.transform = CGAffineTransform.init(scaleX: scaledFactor, y: scaledFactor)
        attrib.alpha = alphaFactor
        return attrib
    }
}
