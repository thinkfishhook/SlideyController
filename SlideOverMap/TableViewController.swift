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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        overScrolling = scrollView.contentOffset.y <= 0 ? true : false
    }
}

// MARK: Slideable

extension TableViewController: Slideable {
    
    func didSnapToBottom()
    {
        tableView.isScrollEnabled = false
    }
    
    func didSnapToTop()
    {
        tableView.isScrollEnabled = true
    }
}
