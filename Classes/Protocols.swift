//
//  Protocols.swift
//  MNkImageSlider
//
//  Created by Malith Nadeeshan on 8/29/19.
//

import Foundation


public protocol MNkSliderCompatable{
    var imageUrl:URL?{get}
    var link:URL?{get}
}
public extension MNkSliderCompatable{
    var link:URL?{
        return nil
    }
}






public protocol MNkSliderDelegate{
    func mnkSliderScrolled(toSlider indexPath:IndexPath,of cell:SliderCell?)
    func mnkSliderBegainDragging()
    func mnkSliderEndDragging()
    func mnkSliderDidSelectSlider(item:Any,_ cell:SliderCell,at indexPath:IndexPath)
    func mnkSliderSizeForItem(at indexPath:IndexPath,of collectionView:UICollectionView)->CGSize
}
public extension MNkSliderDelegate{
    func mnkSliderScrolled(toSlider indexPath:IndexPath,of cell:SliderCell?){}
    func mnkSliderBegainDragging(){}
    func mnkSliderEndDragging(){}
    func mnkSliderDidSelectSlider(item:Any,_ cell:SliderCell,at indexPath:IndexPath){}
    func mnkSliderSizeForItem(at indexPath:IndexPath,of collectionView:UICollectionView)->CGSize{
        return collectionView.bounds.size
    }
}

public protocol MNkSliderDataSource{
    func mnkSliderItemCell(in slider:MNkImageSlider,for indexPath:IndexPath)->SliderCell
    func mnkSliderNumberOfItems(in slider:MNkImageSlider)->Int
}
