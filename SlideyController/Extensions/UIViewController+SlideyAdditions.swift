//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func add(childViewController child: UIViewControllerProtocol)
    {
        guard let viewController = child as? UIViewController else {
            fatalError("add(childViewControllerProtocol: UIViewControllerProtocol) must be called with UIViewController")
        }
        
        addChild(viewController)
    }
}
