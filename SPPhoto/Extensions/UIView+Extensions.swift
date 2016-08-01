//
//  UIView+Extensions.swift
//  SPPhotos
//
//  Created by Itua Ijagbone on 6/8/16.
//  Copyright © 2016 Itua. All rights reserved.
//
/**
    An extension on UIView for convenience
 */
import UIKit

extension UIView {
    /** 
        Creates NSLayout Constraints for child of this view
        
        - Parameter format: The NSLayout Visual Constraint format
        - Parameter views: Array of views to apply constraints too
     */
    func pppve_addConstriaints(format: String, views: UIView...) {
        var dictView = [String : UIView]()
        for (index, element) in views.enumerate() {
            dictView["v\(index)"] = element
        }
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: dictView))
    }
}
