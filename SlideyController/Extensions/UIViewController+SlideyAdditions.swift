//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addChildViewControllerProtocol(child: UIViewControllerProtocol)
    {
        guard let viewController = child as? UIViewController else { fatalError("addChildViewController(_:) must be called with UIViewController") }
        
        addChildViewController(viewController)
    }
}
