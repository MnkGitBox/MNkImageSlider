//
//  ItemIndicators.swift
//  MNkImageSlider
//
//  Created by MNk_Dev on 21/2/19.
//

import Foundation
protocol ItemIndicatorDatasouce:class{
    func numberOfItemsForIndicator()->Int
}
open class ItemIndicators:UIView{
    
    /*....................................
     Mark:- Public configurable paramters
     .....................................*/
    public var selectedColor:UIColor = .black{
        didSet{
//            reloadData()
        }
    }
    public var unSelectedColor:UIColor = .white{
        didSet{
//            reloadData()
        }
    }
    public var isVisibleBackground:Bool = true{
        didSet{
//            backgroundBlurView.isHidden = !isVisibleBackground
        }
    }
    public var padding:CGFloat = 2
    
    
    weak var datasouce:ItemIndicatorDatasouce?
    var indicatorWidth:CGFloat{
        return 5
    }
    var indicatorSpace:CGFloat{
        return 2
    }
    
    private var cellID:String{
        return "indicator_cell_id"
    }
    private var collectionView:UICollectionView!
    
    private func createViews(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = indicatorSpace
        layout.minimumInteritemSpacing = indicatorSpace
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(InidicatorCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.backgroundColor = .clear
    }
    private func insertAndLayoutViews(){
        addSubview(collectionView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = CGRect.init(origin: CGPoint.init(x: padding,
                                                                y: padding),
                                           size: CGSize.init(width: self.bounds.width - padding - padding,
                                                             height: self.bounds.height - padding - padding))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        createViews()
        insertAndLayoutViews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload(){
        collectionView.reloadData()
    }
}

//MARK: - COLLECTION VIEW DELEGATE AND DATASOURCE IMPLIMENTATION
extension ItemIndicators:UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasouce?.numberOfItemsForIndicator() ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        cell.backgroundColor = .white
        cell.layer.cornerRadius = indicatorWidth / 2
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let numberOfItems = datasouce?.numberOfItemsForIndicator() else{return .zero}

        let spaceFreeWidth = collectionView.bounds.width - (indicatorSpace * CGFloat(numberOfItems - 1))
        let calculatedWidth = spaceFreeWidth / CGFloat(numberOfItems)
        let width = indicatorWidth < calculatedWidth ? calculatedWidth : indicatorWidth
        return CGSize.init(width: width,
                           height: collectionView.bounds.height)
    }
    
}

class InidicatorCell:UICollectionViewCell{}
