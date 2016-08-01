//
//  UICollectionViewExtensions.swift
//  SPPhotos
//
//  Created by Itua Ijagbone on 6/8/16.
//  Copyright © 2016 Itua. All rights reserved.
//
/**
    An extension on UICollectionView for convenience
 */
import UIKit

extension UICollectionView {
    /**
        Returns all UICollectionViewCell indexPath within a CGRect
         
        - Parameter rect: The CGRect
        
        - Returns: Any array of NSIndexPath
     */
    func pppce_indexPathsForElementsInRect(rect: CGRect) -> [NSIndexPath]? {
        guard let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElementsInRect(rect) else {
            return nil
        }
        
        var indexPaths = [NSIndexPath]()
        for layoutAttributes in allLayoutAttributes {
            indexPaths.append(layoutAttributes.indexPath)
        }
        
        return indexPaths
    }
}
