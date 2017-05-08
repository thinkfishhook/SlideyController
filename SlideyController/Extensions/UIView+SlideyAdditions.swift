//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit

extension UIView {
    
    func addEquallyPinned(subview: UIView)
    {
        addSubview(subview)
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        leadingAnchor.constraint(equalTo: subview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: subview.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: subview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: subview.bottomAnchor).isActive = true
    }
    
    func addDropShadow(with radius: CGFloat = 5, opacity: Float = 0.2)
    {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }
}
