//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit

@objc public protocol UIViewControllerProtocol {
    
    var view: UIView! { get }
    
    func removeFromParentViewController()
}

extension UIViewController: UIViewControllerProtocol { }
