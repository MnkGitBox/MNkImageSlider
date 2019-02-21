//
//  ItemIndicators.swift
//  MNkImageSlider
//
//  Created by MNk_Dev on 21/2/19.
//

import Foundation
open class ItemIndicators:UIView{
    
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
        //        addSubview(scrollView)
        addSubview(backgroundBlurView)
        addSubview(container)
        container.addSubview(stackView)
        
        //        NSLayoutConstraint.activate([scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
        //                                     scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
        //                                     scrollView.topAnchor.constraint(equalTo: topAnchor),
        //                                     scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)])
        //
        //        NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
        //                                     stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        //                                     stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
        //                                     stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)])
        
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
    
    
    
    
    private func reloadData(){
        updateIndicators()
        setDefaultIndicators()
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
            indicator.backgroundColor = .white
        }
    }
    
    
    private func setActiveIndex(){
        guard let last = lastActiveIndex,
            last != activeIndex
            else{
                lastActiveIndex = activeIndex
                indicators[activeIndex].backgroundColor = .black
                return
        }
        
        let unselectIndi = indicators[last]
        let selectIndi = indicators[activeIndex]
        selectIndicator(false, of: unselectIndi)
        selectIndicator(true, of: selectIndi)
        
        lastActiveIndex = activeIndex
    }
    
    private func selectIndicator(_ isSelect:Bool,of indicatorView:UIView){
        
        let transform = isSelect ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
        let color = isSelect ? UIColor.black : .white
        
        UIView.animate(withDuration: 0.4) {
            indicatorView.backgroundColor = color
            indicatorView.transform = transform
        }
    }
    
}


class Indicator:UIView{
    init(_ tag:Int = 0) {
        super.init(frame: .zero)
        self.tag = tag
        config()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func config(){
        clipsToBounds = true
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 3
        widthAnchor.constraint(equalToConstant: 6).isActive = true
        heightAnchor.constraint(equalToConstant: 6).isActive = true
    }
}
