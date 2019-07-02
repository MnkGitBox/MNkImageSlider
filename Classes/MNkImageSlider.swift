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

public extension MNkSliderCompatable{
    var link:URL?{
        return nil
    }
}


public protocol MNkSliderDelegate{
    func userScrolled(_ sliderData:Any?)
    func userTappedSlider(_ item:Any,at indexPath:IndexPath)
}
public extension MNkSliderDelegate{
    func userScrolled(_ sliderData:Any?){}
    func userTappedSlider(_ item:Any,at indexPath:IndexPath){}
}

open class MNkImageSlider: UIView {
    public enum Sizes:Int{
        case full = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
    }
    
    
    public enum SliderDirection:Int{
        case forward = 0
        case backward = 1
    }
    
    
    /*....................................
     Mark:- Public configurable paramters
     .....................................*/
    public var sliderBackgroundColor:UIColor = .white{
        didSet{
            self.backgroundColor = sliderBackgroundColor
        }
    }
    
    //TODO:- need to set slider indicator inside scrollview and change this as uiedge inserts
    public var indicatorBottomInsets:CGFloat = -8{
        didSet{
            indicatorBottomConstant?.constant = indicatorBottomInsets
            layoutIfNeeded()
        }
    }
    
    public var imagesData:[Any] = []{
        didSet{
            reloadData()
        }
    }
    
    public var delegate:MNkSliderDelegate?
    public var sliderDataSource:MNkSliderDataSource?
    
    var datasource:SliderDataSource?
    
    @IBInspectable public var isRepeat:Bool = false{
        didSet{
            slider.isRepeat = isRepeat
        }
    }
    
    public var delay = TimeInterval(5){
        didSet{
            guard isAnimating else{return}
            stopSlider()
            startSliderAnimation()
        }
    }
    
    public var size:Sizes = .full{
        didSet{
            slider.size = size
        }
    }
    
    public var isActiveIndicator:Bool{
        get{
            return !indicator.isHidden
        }set{
            indicator.isHidden = !newValue
        }
    }
    
    
    /*...................
     Mark:- public views
     ....................*/
    public var indicator:ItemIndicators!
    
    public var slider:Slider!
    
    
    /*....................................
     Mark:- private  parameters
     .....................................*/
    private var currImgIndex:Int = 0
    
    private var placeHolder:UIImage?
    
    private var indicatorBottomConstant:NSLayoutConstraint?
    
    private var isAnimating:Bool = false
    
    private var isUserStartAnimating:Bool = false
    
    private var timer:Timer?
    
    private var sliderDirection:SliderDirection = .forward
    
    
    
    
    
    
    
    
    /*.......................................
     Mark:- Create layout and configure views
     .......................................*/
    private func createViews(){
        slider = Slider(sliderDirection, size, placeHolder)
        slider.sliderDataSource = self
        slider.dataSource = self
        slider.delegate = self
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        indicator = ItemIndicators(imagesData.count)
        indicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func insertAndLayoutViews(){
        addSubview(slider)
        addSubview(indicator)
        
        NSLayoutConstraint.activate([slider.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     slider.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                                     slider.topAnchor.constraint(equalTo: self.topAnchor),
                                     slider.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
        
        indicatorBottomConstant = indicator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: indicatorBottomInsets)
        indicatorBottomConstant?.isActive = true
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: centerXAnchor)])
        
        
    }
    
    public init(frame:CGRect = .zero,_ direction:SliderDirection = .forward, _ placeHolder:UIImage? = nil,_ size:Sizes = .full) {
        self.placeHolder = placeHolder
        self.size = size
        self.sliderDirection = direction
        super.init(frame: frame)
        createViews()
        insertAndLayoutViews()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        createViews()
        insertAndLayoutViews()
    }
    
    
    
    
    
    
    
    /*.........................................
     Mark:- Animation controll func going here
     .........................................*/
    
    public func playSlider(){
        isUserStartAnimating = true
        startSliderAnimation()
    }
    
    private func startSliderAnimation(){
        guard !imagesData.isEmpty,
            isUserStartAnimating
            else {return}
        timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(animateCell), userInfo: nil, repeats: true)
        isAnimating = true
    }
    
    @objc private func animateCell(){
        if slider.isLastItem,isActiveIndicator{indicator.activeIndex = 0}
        slider.animateSlider()
    }
    
    public func stopSlider(){
        guard isAnimating else{return}
        timer?.invalidate()
        timer = nil
        isAnimating = false
    }
    
    
    
    
    
    
    /*.........................................
     Mark:- Animation controll func going here
     .........................................*/
    public func reloadData(){
        slider.reloadData()
        
        guard isActiveIndicator else{return}
        indicator.items = imagesData.count
        indicator.activeIndex = currImgIndex
    }
    
    func removeAll(){
        imagesData.removeAll()
        imagesData = []
    }
    
    
    
    /*.........................................
     Mark:- Send Current visible slider data
     .........................................*/
    private func sendSelectedData(){
        guard let visibleCell = slider.collectionView.visibleCells.first as? SliderCell else{return}
        delegate?.userScrolled(visibleCell.imageData)
    }
    
}






/*.....................................
 Mark:- Slider Delegate methods impli
 ......................................*/
extension MNkImageSlider:SliderDelegate{
    func didSelectSlider(item: Any, at indexPath: IndexPath) {
        delegate?.userTappedSlider(item, at: indexPath)
    }
    
    
    func sliderBegainDragging() {
        stopSlider()
    }
    
    func sliderEndDragging() {
        sendSelectedData()
        startSliderAnimation()
    }
    
    func sliderScrolledPage(_ pageIndex: Int) {
        guard pageIndex != currImgIndex,isActiveIndicator else{return}
        currImgIndex = pageIndex
        indicator.activeIndex = currImgIndex
    }
    
}











/*.....................................
 Mark:- Slider DataSource methods impli
 ......................................*/
extension MNkImageSlider:SliderDataSource{
    public func itemsForSlider() -> [Any] {
        return imagesData
    }
}


extension MNkImageSlider:MNkSliderDataSource{
    public func mnkSliderNumberOfItems(in slider: Slider) -> Int {
        return sliderDataSource?.mnkSliderNumberOfItems(in: slider) ?? 1
    }
    
    public func mnkSliderItemCell(in slider: Slider, for indexPath: IndexPath) -> SliderCell? {
        return sliderDataSource?.mnkSliderItemCell(in: slider, for: indexPath)
    }
}




