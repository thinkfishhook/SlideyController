//
//  Copyright © 2017 John Hoedeman. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var overScrolling: Bool = false
    
}

extension TableViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        overScrolling = scrollView.contentOffset.y <= 0 ? true : false
        print(overScrolling)
    }
    
    func didSnapToBottom()
    {
        tableView.isScrollEnabled = false
    }
    
    func didSnapToTop()
    {
        tableView.isScrollEnabled = true
    }
}
