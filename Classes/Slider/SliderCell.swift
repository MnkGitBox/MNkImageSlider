//
//  SliderCVCell.swift
//
//  Created by Malith Nadeeshan on 2017-12-02.
//  Copyright © 2017 MNkApps. All rights reserved.
//
import SDWebImage

open class SliderCell:UICollectionViewCell{
    
    public var imageData:Any?{
        didSet{
            if let _image = imageData as? UIImage{
                imageView.image = _image
            }
            if let _imageUrl = imageData as? URL{
                imageView.sd_setImage(with: _imageUrl, placeholderImage: placeHolder, options: [], completed: nil)
            }
            if let _imgUrlString = imageData as? String{
                let url = URL(string: _imgUrlString)
                imageView.sd_setImage(with: url, placeholderImage: placeHolder, options: [], completed: nil)
            }
            if let _sliderData = imageData as? MNkSliderCompatable{
                imageView.sd_setImage(with: _sliderData.imageUrl, placeholderImage: placeHolder, options: [], completed: nil)
            }
        }
    }
    
    public var sliderInset:UIEdgeInsets = .zero{
        didSet{
            updateInset()
        }
    }
    
    public var imageContentMode:UIViewContentMode = .scaleToFill{
        didSet{
            imageView.contentMode = imageContentMode
        }
    }
    
    public var placeHolder:UIImage?
    
    private lazy var imageView:UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = self.imageContentMode
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private var leadingConstant:NSLayoutConstraint?
    private var tralingConstant:NSLayoutConstraint?
    private var topConstant:NSLayoutConstraint?
    private var bottomConstant:NSLayoutConstraint?
    
    private func insertAndLayoutSubviews(){
        addSubview(imageView)
        
        leadingConstant = imageView.leadingAnchor.constraint(equalTo: leadingAnchor,constant:sliderInset.left)
        tralingConstant = imageView.trailingAnchor.constraint(equalTo: trailingAnchor,constant:-sliderInset.right)
        topConstant = imageView.topAnchor.constraint(equalTo: topAnchor,constant:sliderInset.top)
        bottomConstant = imageView.bottomAnchor.constraint(equalTo: bottomAnchor,constant:-sliderInset.bottom)
        
        leadingConstant?.isActive = true
        tralingConstant?.isActive = true
        topConstant?.isActive = true
        bottomConstant?.isActive = true
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        insertAndLayoutSubviews()
        backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateInset(){
        leadingConstant?.constant = sliderInset.left
        tralingConstant?.constant = -sliderInset.right
        topConstant?.constant = sliderInset.top
        bottomConstant?.constant = -sliderInset.bottom
        self.layoutIfNeeded()
    }
    
}
