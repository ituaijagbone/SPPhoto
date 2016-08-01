//
//  PhotoViewController.swift
//  SPPhotos
//
//  Created by Itua Ijagbone on 6/8/16.
//  Copyright © 2016 Itua. All rights reserved.
//

import UIKit
import CoreLocation

/// PhotoViewControllerDelegate protocol
protocol PhotoViewControllerDelegate: class {
    /// Notifies parent controller to change the position of the collectionViewCell if its position has changed by any of the views in the PhotoViewController
    func updateCellIndexPath(indexPath: NSIndexPath?)
}

class PhotoViewController: UIViewController {
    var lastTargetSize = CGSizeZero
    var assetIndex: Int!
    
    private var photoView: PhotoView!
    private var scrollerView: HorizontalScrollerView!
    private var initialScrollDone = false
    private var indexPath: NSIndexPath?
    private var statusBarHidden = false
    private var hideLocationLabel = false
    
    weak var delegate: PhotoViewControllerDelegate?
    
    /// UILabel to display the location of where a photo was taken if available
    let locationLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        lb.numberOfLines = 0
        lb.hidden = true
        lb.backgroundColor = UIColor.lightTextColor()
        lb.textAlignment = .Center
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoView = PhotoView()
        
        photoView.delegate = self
        // convert index of selected asset to an NSIndexPath
        indexPath = NSIndexPath(forItem: assetIndex, inSection: 0)
        
        photoView.asset = LibraryAPI.sharedInstance.getPhotoAssetAt(assetIndex)
        setNavigationBarTitle(photoView.asset.creationDate!)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: 30, height: 30)
        scrollerView = HorizontalScrollerView(frame: .zero, collectionViewLayout: flowLayout)
        scrollerView.scrollerDelegate = self
        
        
        self.navigationController!.interactivePopGestureRecognizer!.enabled = false
        
        setupView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // display the image
        updateImageInPhotoView()
    }
    
    override func viewDidLayoutSubviews() {
        if !self.initialScrollDone {
            self.initialScrollDone = true
            
            updateImageCellInCollectionView()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    /// Displays the location where the photo was taken if available
    /// - parameter location: the location about where the picture was taken if available
    func setPhotoLocation(location: CLLocation?) {
        
        if (hideLocationLabel) { return }
        
        guard let location = location else {
            self.locationLabel.hidden = true
            
            return
        }
        
        // reverse geo code using the location
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks: [CLPlacemark]?, error: NSError?) in
            if placemarks != nil && placemarks!.count > 0 {
                var ll = ""
                if (placemarks![0].locality != nil) {
                    ll = "\(placemarks![0].locality!), "
                }
                
                if (placemarks![0].administrativeArea != nil) {
                    ll = ll + "\(placemarks![0].administrativeArea!)"
                }

                self.locationLabel.text = ll
                self.locationLabel.hidden = (ll.isEmpty) ? true : false
            } else {
                self.locationLabel.hidden = false
            }
        }
        
    }
    
    /// Set the UINavigationItem title based on the date the photo was taken/created
    /// - parameter date: the date the photo was created/taken
    func setNavigationBarTitle(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        self.navigationItem.title = dateFormatter.stringFromDate(date)
        
    }
    
    /// Update the image been displaced in the PhotoView's imageView
    func updateImageInPhotoView() {
        photoView.updateImage({(image: UIImage?) in
            guard let image = image else {
                return
            }
            // might not be in the main queue
            dispatch_async(dispatch_get_main_queue()) {
                self.photoView.photoImage = image
                self.setPhotoLocation(self.photoView.asset.location)
            }
            
        })
    }
    
    /// Update the visible region of the HorizontalScrollerView
    func updateImageCellInCollectionView() {
        if (indexPath != nil) {
            self.scrollerView.scrollToItemAtIndexPath(indexPath!, atScrollPosition: .CenteredHorizontally, animated: true)
        }
    }
    
    // MARK: - Setup Views
    /// Setup views
    private func setupView() {
        self.view.addSubview(photoView)
        self.view.addSubview(scrollerView)
        self.view.addSubview(locationLabel)
        
        photoView.translatesAutoresizingMaskIntoConstraints = false
        scrollerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.pppve_addConstriaints("H:|[v0]|", views: photoView)
        view.pppve_addConstriaints("V:|[v0]|", views: photoView)
        view.pppve_addConstriaints("H:|[v0]|", views: scrollerView)
        view.pppve_addConstriaints("H:|[v0]|", views: locationLabel)
        view.pppve_addConstriaints("V:[v0(30)]-[v1(30)]-|", views: locationLabel, scrollerView)
    }
    
}

extension PhotoViewController: PhotoViewDelegate, HorizontalScrollerViewDelegate {
    // MARK: - HorizontalScrollerViewDelegate
    
    /// Change the image displayed in PhotoView's imageView to this one.
    /// - parameter indexPath: the indexPath of the new image
    func changePhotoViewUsing(indexPath: NSIndexPath) {
        self.indexPath = indexPath
        self.assetIndex = indexPath.item
        self.photoView.asset = LibraryAPI.sharedInstance.getPhotoAssetAt(assetIndex)
        self.updateImageInPhotoView()
        setNavigationBarTitle(photoView.asset.creationDate!)
        // notify the parentController to change it's collectionView visible region
        self.delegate?.updateCellIndexPath(self.indexPath)
    }
    
    // MARK: - PhotoViewDelegate
    /// Move to the previous image
    func controllerSwipeRight() {
        if (self.assetIndex - 1 < 0) { return }
        self.assetIndex = self.assetIndex - 1
        self.indexPath = NSIndexPath(forItem: self.assetIndex, inSection: 0)
        self.photoView.asset = LibraryAPI.sharedInstance.getPhotoAssetAt(assetIndex)
        self.updateImageInPhotoView()
        setNavigationBarTitle(photoView.asset.creationDate!)
        self.updateImageCellInCollectionView()
        // notify the parentController to change it's collectionView visible region
        self.delegate?.updateCellIndexPath(self.indexPath)
    }
    
    /// Move the next image
    func controllerSwipeLeft() {
        if (self.assetIndex + 1 >= LibraryAPI.sharedInstance.fetchResultForAllPhotos()?.count) { return }
        self.assetIndex = self.assetIndex + 1
        self.indexPath = NSIndexPath(forItem: self.assetIndex, inSection: 0)
        self.photoView.asset = LibraryAPI.sharedInstance.getPhotoAssetAt(assetIndex)
        self.updateImageInPhotoView()
        setNavigationBarTitle(photoView.asset.creationDate!)
        self.updateImageCellInCollectionView()
        // notify the parentController to change it's collectionView visible region
        self.delegate?.updateCellIndexPath(self.indexPath)
    }
    
    /// Hide all views on the screen expect the PhotoView's imageView
    func hideAllViews() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        statusBarHidden = true
        self.scrollerView.hidden = true
        self.locationLabel.hidden = true
        self.hideLocationLabel = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    /// Restore all the hidden views
    func restoreAllViews() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        statusBarHidden = false
        self.scrollerView.hidden = false
        self.hideLocationLabel = false
        setPhotoLocation(photoView.asset.location)
        self.setNeedsStatusBarAppearanceUpdate()
    }
}
