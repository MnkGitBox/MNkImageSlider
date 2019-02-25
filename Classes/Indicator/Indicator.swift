//
//  Indicator.swift
//  MNkImageSlider
//
//  Created by MNk_Dev on 22/2/19.
//

import Foundation
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
