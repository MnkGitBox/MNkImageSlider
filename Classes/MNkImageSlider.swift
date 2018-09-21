//
//  MNkImageSlider.swift
//
//  Created by Malith Nadeeshan on 2017-12-02.
//  Copyright © 2017 MNkApps. All rights reserved.
//

public protocol MNkSliderCompatable{
    var imageUrl:URL?{get}
    var link:URL?{get}
}

public protocol MNkSliderDelegate{
    func userScrolled(_ sliderData:Any?)
}


open class MNkImageSlider: UIView {
    
    fileprivate let sliderCell = "sliderCell"
    public var imagesData:[Any] = []{
        didSet{
            reloadData()
        }
    }
    public var delegate:MNkSliderDelegate?
    
    public var indicatorSelectColor:UIColor = .black
    public var indicatorUnselectColor:UIColor = .white
    public var isIndicatorBackgroundVisible = true{
        didSet{
            indicatorBackgroundView.isHidden = !isIndicatorBackgroundVisible
        }
    }
    
    public var sliderBackgroundColor:UIColor = .white{
        didSet{
            self.backgroundColor = sliderBackgroundColor
            sliderImageCollectionView.backgroundColor = sliderBackgroundColor
        }
    }
    
    //TODO:- need to set slider indicator inside scrollview and change this as uiedge inserts
    public var indicatorBottomInsets:CGFloat = -8{
        didSet{
            indicatorBottomConstant?.constant = indicatorBottomInsets
            layoutIfNeeded()
        }
    }
    
    public var sliderInsets:UIEdgeInsets = .zero{
        didSet{
            sliderImageCollectionView.reloadData()
        }
    }
    public var imageContentMode:UIViewContentMode = .scaleAspectFill{
        didSet{
            sliderImageCollectionView.reloadData()
        }
    }
    
    fileprivate var currImgIndex:Int = 0
    
    private lazy var sliderImageCollectionView:UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .white
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let indicatorHolderStackView:UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 4
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let indicatorBackgroundView:UIVisualEffectView = {
        let blurEffectView = UIBlurEffect(style: UIBlurEffectStyle.light)
        let view = UIVisualEffectView(effect: blurEffectView)
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var indicatorBottomConstant:NSLayoutConstraint?
    
    private func performLayoutSubViews(){
        
        NSLayoutConstraint.activate([sliderImageCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     sliderImageCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                                     sliderImageCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
                                     sliderImageCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
        
        indicatorHolderStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indicatorBottomConstant = indicatorHolderStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: indicatorBottomInsets)
        indicatorBottomConstant?.isActive = true
        
        indicatorBackgroundView.leadingAnchor.constraint(equalTo: indicatorHolderStackView.leadingAnchor,constant:-4).isActive = true
        indicatorBackgroundView.trailingAnchor.constraint(equalTo: indicatorHolderStackView.trailingAnchor,constant:4).isActive = true
        indicatorBackgroundView.topAnchor.constraint(equalTo: indicatorHolderStackView.topAnchor,constant:-4).isActive = true
        indicatorBackgroundView.bottomAnchor.constraint(equalTo: indicatorHolderStackView.bottomAnchor,constant:4).isActive = true
    }
    
    
    
    private func createIndicatorViews(){
        guard imagesData.count > 1 else{return}
        var index = 0
        while index < imagesData.count {
            let view = UIView()
            view.clipsToBounds = true
            view.backgroundColor = .white
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 3
            view.tag = index
            indicatorHolderStackView.addArrangedSubview(view)
            view.widthAnchor.constraint(equalToConstant: 6).isActive = true
            view.heightAnchor.constraint(equalToConstant: 6).isActive = true
            index += 1
        }
        
    }
    
    
    fileprivate func startAnimationIndicator(at index:Int){
        let indicators = indicatorHolderStackView.subviews
        indicators.forEach { indicator in
            if indicator.tag == index{
                //                selectionOn(of: indicator)
                selectIndicator(true, of: indicator)
            }else{
                //                selectionOff(of: indicator)
                selectIndicator(false, of: indicator)
            }
        }
    }
    
    //    private func selectionOn(of indicator:UIView){
    //        UIView.animate(withDuration: 0.4) {
    //            indicator.backgroundColor = .black
    //            indicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    //        }
    //    }
    //    private func selectionOff(of indicator:UIView){
    //        UIView.animate(withDuration: 0.4) {
    //            indicator.backgroundColor = .white
    //            indicator.transform = .identity
    //        }
    //    }
    
    private func selectIndicator(_ isSelect:Bool,of indicatorView:UIView){
        
        let transform = isSelect ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
        let color = isSelect ? indicatorSelectColor : indicatorUnselectColor
        
        UIView.animate(withDuration: 0.4) {
            indicatorView.backgroundColor = color
            indicatorView.transform = transform
        }
    }
    
    public func reloadData(){
        
        sliderImageCollectionView.reloadData()
        
        self.indicatorHolderStackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        createIndicatorViews()
        startAnimationIndicator(at: currImgIndex)
    }
    
    func removeAll(){
        imagesData.removeAll()
        imagesData = []
        
        self.indicatorHolderStackView.subviews.forEach { view in
            view.removeFromSuperview()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(sliderImageCollectionView)
        addSubview(indicatorBackgroundView)
        addSubview(indicatorHolderStackView)
        
        
        sliderImageCollectionView.register(SliderCVCell.self, forCellWithReuseIdentifier: sliderCell)
        
        performLayoutSubViews()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        
        addSubview(sliderImageCollectionView)
        addSubview(indicatorBackgroundView)
        addSubview(indicatorHolderStackView)
        
        sliderImageCollectionView.register(SliderCVCell.self, forCellWithReuseIdentifier: sliderCell)
        
        performLayoutSubViews()
    }
    
    private func sendSelectedData(){
        guard let visibleCell = sliderImageCollectionView.visibleCells.first as? SliderCVCell else{return}
        delegate?.userScrolled(visibleCell.imageData)
    }
    
}


extension MNkImageSlider:UIScrollViewDelegate{
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else{return}
        sendSelectedData()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        sendSelectedData()
        
        let index:Int = Int(scrollView.contentOffset.x / (scrollView.contentSize.width / CGFloat(imagesData.count)))
        guard index != currImgIndex else{return}
        currImgIndex = index
        startAnimationIndicator(at: currImgIndex)
    }
    
}

extension MNkImageSlider:UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sliderCell, for: indexPath) as! SliderCVCell
        cell.imageData = imagesData[indexPath.item]
        cell.sliderInset = sliderInsets
        cell.imageContentMode = imageContentMode
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.size
        return size
    }
    
    
    
}









