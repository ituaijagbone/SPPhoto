//
//  ViewController.swift
//  SPPhotos
//
//  Created by Itua Ijagbone on 6/8/16.
//  Copyright © 2016 Itua. All rights reserved.
//

import UIKit
import CoreGraphics

/// Displays all the photos in the iOS PhotosApp in a UICollectionView. Taping a photo opens the photo in UIViewController

class AllPhotosViewController: UICollectionViewController {
    
    private let photoCellIdentifier = "PhotoCell"
    private var assetThumbnailSize = CGSize(width: 0, height: 0)
    private var previousPreheatRect = CGRectZero
    private var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.collectionView?.registerClass(PhotoCell.self, forCellWithReuseIdentifier: photoCellIdentifier)
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        
        resetCachedAssets()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Determine the size of the thumbnails to request from the LibraryAPI
        let scale = UIScreen.mainScreen().scale
        let size = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetThumbnailSize = CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Begin caching assets in and around collection view's visible rect.
        updateCachedAssets()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: - UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = LibraryAPI.sharedInstance.fetchResultForAllPhotos()?.count {
            return count
        }
        
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // open detail view of the image
        // push PhotoViewController to top of navigationController
        let destinationController = PhotoViewController()
        destinationController.delegate = self
        destinationController.assetIndex = indexPath.item
        selectedIndex = indexPath.item
        self.navigationController?.pushViewController(destinationController, animated: true)
    }
    
    // MARK: - Asset Caching
    /// Stop caching assets
    private func resetCachedAssets() {
        LibraryAPI.sharedInstance.stopCachingAllAsset()
        previousPreheatRect = CGRectZero
    }
    
    /// Update cached assets when the UICollectionView visible area changes.
    /// Caching makes loading faster since we will likely have many number of images
    private func updateCachedAssets() {
        let isVisible = self.isViewLoaded() && (self.view.window != nil )
        if isVisible { return }
        
        // The preheat window is twice the height of the visible rect.
        var preheatRect = self.collectionView!.bounds
        preheatRect = CGRectInset(preheatRect, 0.0, -0.5 * CGRectGetHeight(preheatRect))
        
        /*
         Check if the collection view is showing an area that is significantly
         different to the last preheated area.
         */
        let delta = CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect)
        if (delta > CGRectGetHeight(self.collectionView!.bounds) / 3.0) {
            var addedIndexPaths = [NSIndexPath]()
            var removedIndexPaths = [NSIndexPath]()
            
            computeDifferenceBetweenRect(self.previousPreheatRect, andRect: preheatRect, removedHandler: { (removedRect: CGRect) in
                if let indexPaths = self.collectionView?.pppce_indexPathsForElementsInRect(removedRect) {
                    removedIndexPaths.appendContentsOf(indexPaths)
                }
                }, addedHandler: { (addedRect: CGRect) in
                    if let indexPaths = self.collectionView?.pppce_indexPathsForElementsInRect(addedRect) {
                        addedIndexPaths.appendContentsOf(indexPaths)
                    }
            })
            
            // Update the assets the LibraryAPI is caching.
            LibraryAPI.sharedInstance.startCachingAssetsFor(addedIndexPaths, assetThumbnailSize: assetThumbnailSize)
            LibraryAPI.sharedInstance.stopCachingAssetsFor(removedIndexPaths, assetThumbnailSize: assetThumbnailSize)
            
            // Store the preheat rect to compare against in the future.
            self.previousPreheatRect = preheatRect
        }
    }
    
    /// Helper function to compute difference between CGRects to know if they are in the visible region.
    /// - parameter oldRect: of type CGRect
    /// - parameter newRect: of type CGRect
    /// - parameter removedHandler: Callback to handle assets to be removed from cache based on the CGRect computation
    /// - parameter addedHandler: Callback to handle assets to be added to cache based on the CGRect computation
    private func computeDifferenceBetweenRect(oldRect: CGRect, andRect newRect: CGRect, removedHandler:(removedRect: CGRect)-> Void, addedHandler: (addedRect: CGRect) -> Void) {
        
        if (CGRectIntersectsRect(newRect, oldRect)) {
            let oldMaxY = CGRectGetMaxY(oldRect)
            let oldMinY = CGRectGetMinY(oldRect)
            let newMaxY = CGRectGetMaxY(newRect)
            let newMinY = CGRectGetMinY(newRect)
            
            if (newMaxY > oldMaxY) {
                let rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY))
                addedHandler(addedRect: rectToAdd)
            }
            
            if (oldMinY > newMinY) {
                let rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY))
                addedHandler(addedRect: rectToAdd)
            }
            
            if (newMaxY < oldMaxY) {
                let rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY))
                removedHandler(removedRect: rectToRemove)
            }
            
            if (oldMinY < newMinY) {
                let rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY))
                removedHandler(removedRect: rectToRemove)
            }
        } else {
            addedHandler(addedRect: newRect)
            removedHandler(removedRect: oldRect)
        }
    }
}

extension AllPhotosViewController: UICollectionViewDelegateFlowLayout, PhotoViewControllerDelegate {
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // calculate effective item size
        let numberOfCellInRow : Int = 4
        let padding : Int = 3
        let collectionCellWidth : CGFloat = (self.view.frame.size.width/CGFloat(numberOfCellInRow)) - CGFloat(padding)
        return CGSize(width: collectionCellWidth , height: collectionCellWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: PhotoViewControllerDelegate
    /// Uodates the visible section of the collectionView if its visible region has been changed by its children UIViewControllers
    /// - parameter indexPath: the indexPath to scroll to in the collectionView
    func updateCellIndexPath(indexPath: NSIndexPath?) {
        if (indexPath != nil && indexPath!.item != selectedIndex) {
            self.collectionView!.scrollToItemAtIndexPath(indexPath!, atScrollPosition: .CenteredVertically, animated: false)
        }
    }
}
