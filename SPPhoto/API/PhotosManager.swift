//
//  PhotosManager.swift
//  SPPhotos
//
//  Created by Itua Ijagbone on 6/8/16.
//  Copyright © 2016 Itua. All rights reserved.
//

import Foundation
import Photos

/// Handles photo request from client to the iOS Photos Framework
class PhotosManager: NSObject {
    private var allPhotos: PHFetchResult?
    private let imageCachingManager: PHCachingImageManager?
    
    override init() {
        imageCachingManager = PHCachingImageManager()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssetsWithOptions(fetchOptions)
    }
    
    /// Returns all photos from the iOS Photos app
    /// - returns: A `PHFetchRequest` containing all photos from iOS Photos app
    func fetchResultForAllPhotos() -> PHFetchResult? {
        return allPhotos
    }
    
    /// Gets a PHAsset from the allPhotos array
    /// - parameter index: the index of the PHAsset
    /// - returns: A PHAsset
    func getPhotoAssetAt(index: Int) -> PHAsset? {
        return allPhotos?[index] as? PHAsset
    }
    
    /// Returns the imageCachingManager used in handling caching
    /// - returns: PHImageCachingManager
    func getImageCachingManager() -> PHCachingImageManager? {
        return imageCachingManager
    }

    /// Stops the imageCachingManager from caching assets
    func stopCachingAllAsset() {
        imageCachingManager?.stopCachingImagesForAllAssets()
    }
    
    /// Tells the imageCachingManager to cache the given assets
    /// - parameter assetsIndexPath: the indexPaths of the assets to cache
    /// - parameter assetThmbnailSize: the thumbnail size used in specifing the size of the assets
    func startCachingAssetsFor(assetsIndexPaths: [NSIndexPath], assetThumbnailSize: CGSize) {
        guard let assetsToStartCaching = indexPathsToPHAssets(assetsIndexPaths) else {
            return
        }
        
        imageCachingManager?.startCachingImagesForAssets(assetsToStartCaching, targetSize: assetThumbnailSize, contentMode: .AspectFill, options: nil)
    }
    
    /// Tells the imageCachingManager to remove the given assets from the cache
    /// - parameter assetsIndexPath: the indexPaths of the assets to be removed
    /// - parameter assetThmbnailSize: the thumbnail size used in specifing the size of the assets
    func stopCachingAssetsFor(assetsIndexPaths: [NSIndexPath], assetThumbnailSize: CGSize)  {
        guard let assetsToStopCaching = indexPathsToPHAssets(assetsIndexPaths) else {
            return
        }
        
        imageCachingManager?.stopCachingImagesForAssets(assetsToStopCaching, targetSize: assetThumbnailSize, contentMode: .AspectFill, options: nil)
    }
    
    /// Converts indexPaths of PHAssets to their actual PHAsset
    /// - parameter indexPath: array of indexPaths
    /// - returns: An array of PHAsset
    private func indexPathsToPHAssets(indexPaths: [NSIndexPath]) -> [PHAsset]? {
        
        guard let photos = allPhotos else {
            return nil
        }
        
        var assets:[PHAsset]? = [PHAsset]();
        for indexPath in indexPaths {
            let asset = photos[indexPath.item] as! PHAsset;
            assets?.append(asset)
        }
        
        return assets
    }
}