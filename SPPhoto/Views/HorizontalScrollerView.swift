//
//  HorizontalScrollerView.swift
//  SPPhotos
//
//  Created by Itua Ijagbone on 6/8/16.
//  Copyright © 2016 Itua. All rights reserved.
//

import UIKit

/// HorizontalScrollerViewDelegat Protocol
protocol HorizontalScrollerViewDelegate: class {
    /// Notify controller to change display of image in PhotoView to this image
    /// - parameter indexPath: The indexPath of the selected element
    func changePhotoViewUsing(indexPath: NSIndexPath)
}

/**
 Uses UICollectionView to display thumbnails of images in horizontal direction.
 Selecting on thumbnail updates the the image displayed on the PhotoView's UIImageView
 */
class HorizontalScrollerView: UICollectionView {
    private let photoCellIdentifier = "PhotoCell"
    private var assetThumbnailSize = CGSize(width: 0, height: 0)
    
    weak var scrollerDelegate: HorizontalScrollerViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Setup subviews
    /// Setup subviews
    func setupView() {
        registerClass(PhotoCell.self, forCellWithReuseIdentifier: photoCellIdentifier)
        self.delegate = self
        self.dataSource = self
        
        self.backgroundColor = UIColor.clearColor()
        
        let scale = UIScreen.mainScreen().scale
        let size = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetThumbnailSize = CGSize(width: size.width * scale, height: size.height * scale)
        
    }
}

extension HorizontalScrollerView: UICollectionViewDelegate, UICollectionViewDataSource {
     // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = LibraryAPI.sharedInstance.fetchResultForAllPhotos()?.count {
            return count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let photoAsset = LibraryAPI.sharedInstance.getPhotoAssetAt(indexPath.item) else {
            return PhotoCell()
        }
        
        let photoCell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellIdentifier, forIndexPath: indexPath) as! PhotoCell
        photoCell.representedAssetIdentifier = photoAsset.localIdentifier
        
        // Request an image for the asset from the LibraryAPI.
        if let imageManager = LibraryAPI.sharedInstance.getImageCachingManager() {
            imageManager.requestImageForAsset(photoAsset, targetSize: assetThumbnailSize, contentMode: .AspectFill, options: nil, resultHandler: {(result: UIImage?, info: [NSObject : AnyObject]?) -> () in
                // Set the cell's thumbnail image if it's still showing the same asset.
                if result != nil && photoCell.representedAssetIdentifier == photoAsset.localIdentifier {
                    photoCell.photoImage = result
                }
            })
        }
        
        return photoCell
        
    }
    
     // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        /// notify controller to change image displayed by PhotoView
        self.scrollerDelegate?.changePhotoViewUsing(indexPath)
    }
}


