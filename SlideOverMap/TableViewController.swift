//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit
import SlideyController

class TableViewController: UITableViewController {
    
    var overScrolling: Bool = false
}

// MARK: Scroll View Delegate

extension TableViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView)
    {
        overScrolling = scrollView.contentOffset.y <= 0 ? true : false
    }
}

// MARK: Slideable

extension TableViewController: FrontSlideable {
    
    func didSnapToBottom()
    {
        tableView.scrollEnabled = false
    }
    
    func didSnapToTop()
    {
        tableView.scrollEnabled = true
    }
}
