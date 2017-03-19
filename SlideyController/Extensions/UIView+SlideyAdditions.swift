//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit

extension UIView {
    
    func addEquallyPinnedSubview(subview: UIView)
    {
        addSubview(subview)
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        leadingAnchor.constraintEqualToAnchor(subview.leadingAnchor).active = true
        trailingAnchor.constraintEqualToAnchor(subview.trailingAnchor).active = true
        topAnchor.constraintEqualToAnchor(subview.topAnchor).active = true
        bottomAnchor.constraintEqualToAnchor(subview.bottomAnchor).active = true
    }
    
    func addDropShadow(radius: CGFloat = 5, opacity: Float = 0.2)
    {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.blackColor().CGColor
        
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }
}
