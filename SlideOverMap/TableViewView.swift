//
//  Copyright © 2017 John Hoedeman. All rights reserved.
//

import UIKit

class TableViewView: UIView {
    
    var tableView: UITableView!
    var beginConstant: CGFloat!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        panGestureRecognizer = self.gestureRecognizers?.first as! UIPanGestureRecognizer
        panGestureRecognizer.delegate = self
    }
    
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer!
    fileprivate var recognizeSimultaneously: Bool = false
}

extension TableViewView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}

extension TableViewView: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if beginConstant < self.frame.height * 0.5 {
            
            if scrollView.contentOffset.y == 0 {
                tableView.isScrollEnabled = false
                panGestureRecognizer.isEnabled = true
            }
            else {
                tableView.isScrollEnabled = true
                panGestureRecognizer.isEnabled = false
            }
        }
        else {
            tableView.isScrollEnabled = false
            panGestureRecognizer.isEnabled = true
        }
    }
}
