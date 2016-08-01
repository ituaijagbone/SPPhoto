//
//  LibraryAPI.swift
//  SPPhotos
//
//  Created by Itua Ijagbone on 6/8/16.
//  Copyright © 2016 Itua. All rights reserved.
//

import Foundation
import Photos
/**
    Provides a single interface to the iOS Photos Library and any other service that will be added such as accessing images from a photo web service.
 
    Holds instance of the PhotosManager, which is currently responsible for handling request to the iOS Photos Framework
 */
class LibraryAPI: NSObject{
    
    /// PhotoManager instance
    private let photosManager: PhotosManager
    
    // singleton instance
    static let sharedInstance = LibraryAPI()
    
    private override init() {
        photosManager = PhotosManager()
        super.init()
    }
    
    /// Tells PhotoManager to return all photos from the iOS Photos app
    /// - returns: A `PHFetchRequest` containing all photos from iOS Photos app
    func fetchResultForAllPhotos() -> PHFetchResult? {
        return photosManager.fetchResultForAllPhotos()
    }
    
    /// Gets a PHAsset from the allPhotos array
    /// - parameter index: the index of the PHAsset
    /// - returns: A PHAsset
    func getPhotoAssetAt(index: Int) -> PHAsset? {
        return photosManager.getPhotoAssetAt(index)
    }
    
    /// Tells PhotoManager to return the image caching manager used in handling caching
    /// - returns: PHImageCachingManager
    func getImageCachingManager() -> PHCachingImageManager? {
        return photosManager.getImageCachingManager()
    }
    
    /// Tells PhotoManager to stop caching assets
    func stopCachingAllAsset() {
        return photosManager.stopCachingAllAsset()
    }
    
    /// Tells PhotoManager to cache the given assets
    /// - parameter assetsIndexPath: the indexPaths of the assets to cache
    /// - parameter assetThmbnailSize: the thumbnail size used in specifing the size of the assets
    func startCachingAssetsFor(assetsIndexPaths: [NSIndexPath], assetThumbnailSize: CGSize) {
        if (assetsIndexPaths.count == 0) {
            return
        }
        
        photosManager.startCachingAssetsFor(assetsIndexPaths, assetThumbnailSize: assetThumbnailSize)
    }
    
    /// Tells PhotoManager to remove the given assets from the cache
    /// - parameter assetsIndexPath: the indexPaths of the assets to be removed
    /// - parameter assetThmbnailSize: the thumbnail size used in specifing the size of the assets
    func stopCachingAssetsFor(assetsIndexPaths: [NSIndexPath], assetThumbnailSize: CGSize)  {
        photosManager.stopCachingAssetsFor(assetsIndexPaths, assetThumbnailSize: assetThumbnailSize)
    }
    
    
}