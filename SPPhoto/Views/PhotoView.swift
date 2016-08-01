//
//  PhotoView.swift
//  SPPhotos
//
//  Created by Itua Ijagbone on 6/8/16.
//  Copyright © 2016 Itua. All rights reserved.
//

import UIKit
import Photos

/**
     PhotoViewDelegate Protocol
 */
protocol PhotoViewDelegate: class {
    /// Notify controller to move to previous image
    func controllerSwipeLeft()
    /// Notify controller to move to next image
    func controllerSwipeRight()
    /// Notify controller to hide all views except for the imageView
    func hideAllViews()
    /// Notify controller to restore all hidden views
    func restoreAllViews()
}

/// Displays a selected image through its UIImageView in the PhotoViewController. PhotoView allows images to be zoomed in to allow complete visible of the image. 
/// 
/// PhotoView allows images to be swiped left and right. This also updates the HorizontalScollerView
class PhotoView: UIView {
    private let cellId = "Cell"
    private var isZoomed = false

    weak var delegate: PhotoViewDelegate?
    
    var asset: PHAsset!
    
    /**
        UIImage that holds current image. Updates imageView.image when set.
     */
    var photoImage:UIImage! {
        didSet {
            imageView.image = photoImage
        }
    }
    
    /**
        UIImageView to display image
     */
    let imageView: UIImageView = {
        let iv = UIImageView(frame: CGRectMake(0, 0, 600, 600))
        iv.backgroundColor = UIColor.whiteColor()
        iv.contentMode = .ScaleAspectFit
        iv.userInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    /**
         Request for UIImage to display on `imageView` from PHImageManager
         
         - Parameter imageHandler: Callback to handle UIImage when request completed
     */
    func updateImage(imageHandler: (image: UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .HighQualityFormat
        options.networkAccessAllowed = true
        
        // use PHImageManager to reqeust for image using the given asset and target size
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize(), contentMode: .AspectFit, options: options, resultHandler: {(result: UIImage?, info: [NSObject: AnyObject]?) in
            // handle completion of request
            imageHandler(image: result)
            
        })
    }
    
    /**
        Calculates the required image size to be displaced.

        - returns: The new image size
     */
    func targetSize() -> CGSize {
        let scale = UIScreen.mainScreen().scale;
        let targetSize = CGSizeMake(CGRectGetWidth(self.imageView.bounds) * scale, CGRectGetHeight(self.imageView.bounds) * scale)
        return targetSize
    }
    
    // MARK: - Swipe left and right
    /**
         Tells delegate to the next image.
     */
    func swipeLeft() {
        delegate?.controllerSwipeLeft()
    }
    
    /**
        Tells delegate to the previous image.
    */
    func swipeRight() {
        delegate?.controllerSwipeRight()
    }
    
    // MARK: - Zoom In and Zoom Out
    /**
        'Zooms in or out' when the image is tapped.
    */
    func toogleZoom() {
        if isZoomed {
            isZoomed = false
            zoomOutImage()
        } else {
            isZoomed = true
            zoomImage()
        }
    }
    
    /**
         Zooms In on an image it is tapped. Notifies the controller to hide all other views.
    */
    func zoomImage() {
        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .CurveEaseOut, animations: {
            () -> Void in
            self.delegate?.hideAllViews()
            self.backgroundColor = UIColor.blackColor()
            self.imageView.backgroundColor = UIColor.blackColor()
            }, completion: nil)
    }
    
    /**
        Zooms Out on an image when it is tapped. Notifies the controller to restore all hiden views.
     */
    func zoomOutImage() {
        UIView.animateWithDuration(0.25, animations: {
            () -> Void in
            }, completion: { (didComplete) in
                self.backgroundColor = UIColor.whiteColor()
                self.imageView.backgroundColor = UIColor.whiteColor()
                self.delegate?.restoreAllViews()
        })
    }
    
    // MARK: - Setup subviews
    /**
     Setup subviews using AutoLayout Constraints
     */
    func setupView() {
        self.backgroundColor = UIColor.whiteColor()
        
        // set up gestures
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PhotoView.swipeLeft))
        leftSwipe.direction = .Left
        self.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PhotoView.swipeRight))
        rightSwipe.direction = .Right
        self.addGestureRecognizer(rightSwipe)
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PhotoView.toogleZoom)))
        
        addSubview(imageView)
        pppve_addConstriaints("H:|[v0]|", views: imageView)
        pppve_addConstriaints("V:|[v0]|", views: imageView)
    }
    
}