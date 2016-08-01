//
//  PhotoCell.swift
//  SPPhotos
//
//  Created by Itua Ijagbone on 6/8/16.
//  Copyright © 2016 Itua. All rights reserved.
//

import UIKit
/// This serves as the cell for the UICollectionView. Has a UIImageView that displays the thumbnail of the images
class PhotoCell: UICollectionViewCell {
    var representedAssetIdentifier: String!
    
    /** 
        Property Observer on UIImage.
        Updates UIImageView.image when set
    */
    var photoImage: UIImage! {
        didSet {
            imageView.image = photoImage
        }
    }
    
    // UIImageView holding selected photo
    private let imageView: UIImageView = {
        let imv = UIImageView()
        imv.image = UIImage(named: "defaultCellPhoto")
        imv.contentMode = .ScaleAspectFill
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPhotoCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPhotoCell()
    }
    
    // MARK: - Setup subviews
    /**
        Setup subviews using AutoLayout Constraints
     */
    private func setupPhotoCell() {
        addSubview(imageView)
        self.pppve_addConstriaints("H:|[v0]|", views: imageView)
        self.pppve_addConstriaints("V:|[v0]|", views: imageView)
    }
}
