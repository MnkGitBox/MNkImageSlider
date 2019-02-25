//
//  ItemIndicators.swift
//  MNkImageSlider
//
//  Created by MNk_Dev on 21/2/19.
//

import Foundation
open class ItemIndicators:UIView{
    
    /*....................................
     Mark:- Public configurable paramters
     .....................................*/
    public var selectedColor:UIColor = .black{
        didSet{
            reloadData()
        }
    }
    public var unSelectedColor:UIColor = .white{
        didSet{
            reloadData()
        }
    }
    public var isVisibleBackground:Bool = true{
        didSet{
            backgroundBlurView.isHidden = !isVisibleBackground
        }
    }
    
    
    
    
    
    
    
    
    /*...............................................
     Mark:- private and internal views and parameters
     ................................................*/
    var items:Int{
        willSet{
            guard oldItems == newValue else{
                createIndicators(for: newValue)
                return
            }
            reloadData()
        }
        didSet{
            oldItems = items
        }
    }
    
    var activeIndex:Int = 0{
        didSet{
            setActiveIndex()
        }
    }
    
    private var lastActiveIndex:Int?
    private var oldItems:Int = 0
    
    private var scrollView:UIScrollView!
    private var stackView:UIStackView!
    private var container:UIView!
    private var backgroundBlurView:UIVisualEffectView!
    
    private var indicators = [Indicator]()
    
    
    
    
    
    
    
    
    
    /*.......................................
     Mark:- Create layout and configure views
     .......................................*/
    private func createViews(){
        
        clipsToBounds = true
        layer.cornerRadius = 3
        
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let blurEffectView = UIBlurEffect(style: UIBlurEffectStyle.light)
        backgroundBlurView = UIVisualEffectView(effect: blurEffectView)
        backgroundBlurView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func insertAndLayoutSubviews(){
        addSubview(backgroundBlurView)
        addSubview(container)
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([backgroundBlurView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     backgroundBlurView.trailingAnchor.constraint(equalTo:trailingAnchor),
                                     backgroundBlurView.topAnchor.constraint(equalTo: topAnchor),
                                     backgroundBlurView.bottomAnchor.constraint(equalTo:bottomAnchor)])
        
        NSLayoutConstraint.activate([container.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                                        constant: 4),
                                     container.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                                         constant: -4),
                                     container.topAnchor.constraint(equalTo: topAnchor,
                                                                    constant:4),
                                     container.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                                       constant: -4)])
        
        NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                                     stackView.topAnchor.constraint(equalTo: container.topAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)])
        
        
        
    }
    
    
    init(_ items:Int = 0) {
        self.items = items
        super.init(frame: .zero)
        createViews()
        insertAndLayoutSubviews()
        backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*.............................................
     Mark:- Update indicator view func going here
     ............................................*/
    private func reloadData(){
        updateIndicators()
        setDefaultIndicators()
        setActiveIndex()
    }
    
    private func createIndicators(for noItems:Int){
        
        for tag in 0..<noItems{
            let indicator = Indicator(tag)
            indicators.append(indicator)
            stackView.addArrangedSubview(indicator)
        }
        
    }
    
    private func updateIndicators(){
        guard items != indicators.count else{return}
        
        guard items > indicators.count else{
            removeIndicators()
            return
        }
        addIndicators()
    }
    
    private func removeIndicators(){
        let removeItems = indicators.count - items
        for _ in 0..<removeItems{
            let indicator = indicators.removeLast()
            indicator.removeFromSuperview()
        }
    }
    
    private func addIndicators(){
        let itemToAdd = items - indicators.count
        for _ in 0..<itemToAdd{
            let indicator = Indicator()
            indicators.append(indicator)
            stackView.addArrangedSubview(indicator)
        }
    }
    
    private func setDefaultIndicators(){
        for (index,indicator) in indicators.enumerated(){
            indicator.tag = index
            indicator.backgroundColor = unSelectedColor
        }
    }
    
    
    private func setActiveIndex(){
        guard let last = lastActiveIndex,
            last != activeIndex
            else{
                lastActiveIndex = activeIndex
                let indicator =  indicators[activeIndex]
                selectIndicator(true, of: indicator, isAnimate: false)
                return
        }
        
        let unselectIndi = indicators[last]
        let selectIndi = indicators[activeIndex]
        selectIndicator(false, of: unselectIndi)
        selectIndicator(true, of: selectIndi)
        
        lastActiveIndex = activeIndex
    }
    
    private func selectIndicator(_ isSelect:Bool,of indicatorView:UIView,isAnimate animate:Bool = true){
        
        let transform = isSelect ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
        let color = isSelect ? selectedColor : unSelectedColor
        let duration:TimeInterval = animate ? 0.4 : 0.0
        
        UIView.animate(withDuration: duration) {
            indicatorView.backgroundColor = color
            indicatorView.transform = transform
        }
    }
    
}

