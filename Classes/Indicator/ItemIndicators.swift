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
    public var selectedColor:UIColor = .black{didSet{collectionView.reloadData()}}
    public var unSelectedColor:UIColor = .white{didSet{collectionView.reloadData()}}
    public var padding:CGFloat = 2
    
    var selectedIndex:Int  = 0{
        didSet{
            collectionView.reloadData()
            collectionView.performBatchUpdates(nil) { [unowned self]_ in
                self.setDisplayActiveIndicator()
            }
        }
    }
    weak var datasouce:ItemIndicatorDatasouce?
    public var indicatorViewSize:CGFloat = 5
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
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(InidicatorView.self, forCellWithReuseIdentifier: cellID)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
    }
    private func insertAndLayoutViews(){
        addSubview(collectionView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        calculateCVFrame()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        self.clipsToBounds = true
        createViews()
        insertAndLayoutViews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload(){
        calculateCVFrame()
        collectionView.reloadData()
    }
    
    private func setDisplayActiveIndicator(){
        let visibleCellIndexes = collectionView.indexPathsForVisibleItems.map{$0.item}
        let isVisibleActiveIndicator = !visibleCellIndexes.filter{$0==selectedIndex}.isEmpty
        guard !isVisibleActiveIndicator,
            !visibleCellIndexes.isEmpty else{return}
        collectionView.scrollToItem(at: IndexPath.init(row: selectedIndex, section: 0), at: .right, animated: true)
    }
    private func calculateCVFrame(){
        collectionView.frame = CGRect.init(origin: CGPoint.init(x: padding,
                                                                      y: padding),
                                                 size: CGSize.init(width: self.bounds.width - padding - padding,
                                                                   height: self.bounds.height - padding - padding))
    }
    
    public func insetBackground(_ view:UIView){
        self.backgroundColor = .clear
        self.insertSubview(view, at: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     view.topAnchor.constraint(equalTo: self.topAnchor),
                                     view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                                     view.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
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
        cell.backgroundColor = indexPath.item == selectedIndex ? selectedColor : unSelectedColor
        cell.transform = indexPath.item == selectedIndex ? CGAffineTransform.identity : CGAffineTransform.init(scaleX: 0.95, y: 0.95)
        cell.layer.cornerRadius = indicatorViewSize / 2
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let numberOfItems = datasouce?.numberOfItemsForIndicator() else{return .zero}
        let spaceFreeWidth = collectionView.bounds.width - indicatorSpace * CGFloat(numberOfItems - 1)
        let calculatedWidth = spaceFreeWidth / CGFloat(numberOfItems)
        let width = indicatorViewSize < calculatedWidth ? calculatedWidth : indicatorViewSize
        return CGSize.init(width: width,
                           height: collectionView.bounds.height)
    }
}

class InidicatorView:UICollectionViewCell{}
