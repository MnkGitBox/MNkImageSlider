//
//  SliderCVCell.swift
//
//  Created by Malith Nadeeshan on 2017-12-02.
//  Copyright © 2017 MNkApps. All rights reserved.
//
import SDWebImage
class SliderCVCell:UICollectionViewCell{
    
    var imageData:Any?{
        didSet{
            if let _image = imageData as? UIImage{
                imageView.image = _image
            }
            if let _imageUrl = imageData as? URL{
                imageView.sd_setImage(with: _imageUrl, placeholderImage: UIImage(), options: [], completed: nil)
            }
            if let _imgUrlString = imageData as? String{
                let url = URL(string: _imgUrlString)
                imageView.sd_setImage(with: url, placeholderImage: nil, options: [], completed: nil)
            }
//            if let sliderData = imageData as? HomeFeedData.SliderOb{
//                imageView.sd_setImage(with: sliderData.imgUrl, placeholderImage: UIImage(), options: [], completed: nil)
//            }
        }
    }
    
    private let imageView:UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        
        NSLayoutConstraint.activate([imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     imageView.topAnchor.constraint(equalTo: topAnchor),
                                     imageView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
