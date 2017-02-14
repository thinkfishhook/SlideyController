//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit

protocol Slideable {
    
}

private enum Position {
    case Bottom
    case Top
}

private enum GestureState {
    case Active
    case Inactive
}

class SlideyController<SlideViewController: UIViewController>: UIViewController, UIGestureRecognizerDelegate where SlideViewController: Slideable {
    
    var frontViewController: SlideViewController?
    var backViewController: UIViewController?
    
    func setBack(_ back: MapViewController)
    {
        mapViewController = back
        addChildViewController(back)
    }
    
    func setSlidey(_ slidey: TableViewController)
    {
        tableViewController = slidey
        addChildViewController(slidey)
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        minTopConstant = view.frame.height * 0.2
        maxTopConstant = view.frame.height * 0.8
        slideyTopConstraint.constant = minTopConstant
        beginConstant = slideyTopConstraint.constant
        
        backView.addSubview(mapViewController.view)
        mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: mapViewController.view, attribute: .top, relatedBy: .equal, toItem: backView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: mapViewController.view, attribute: .leading, relatedBy: .equal, toItem: backView, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: mapViewController.view, attribute: .trailing, relatedBy: .equal, toItem: backView, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: mapViewController.view, attribute: .bottom, relatedBy: .equal, toItem: backView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        slideyView.addSubview(tableViewController.view)
        tableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: tableViewController.view, attribute: .top, relatedBy: .equal, toItem: slideyView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableViewController.view, attribute: .leading, relatedBy: .equal, toItem: slideyView, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableViewController.view, attribute: .trailing, relatedBy: .equal, toItem: slideyView, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableViewController.view, attribute: .bottom, relatedBy: .equal, toItem: slideyView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        panGestureRecognizer = slideyView.gestureRecognizers?.first as! UIPanGestureRecognizer
        panGestureRecognizer.delegate = self
    }
    
    // MARK: Interface Builder Actions
    @IBAction func gestureRecognized(_ sender: UIPanGestureRecognizer)
    {
        if panGestureRecognizingState == .Inactive && tableViewController.overScrolling == true  {
            panGestureRecognizingState = .Active
        }
        
        guard panGestureRecognizingState == .Active else { return }
        
        let translation = sender.translation(in: self.view)
        
        switch sender.state {
        case .changed:
            slideyTopConstraint.constant = beginConstant + translation.y
            tableViewController.tableView.isScrollEnabled = false
        case .ended:
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: {
                self.slideyTopConstraint.constant = self.newTopConstant(translationY: translation.y)
                self.view.layoutIfNeeded()
            })
            tableViewController.tableView.isScrollEnabled = true
            beginConstant = slideyTopConstraint.constant
        default:
            break
        }
    }
    
    // MARK: Gesture Recognizer Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    // MARK: Private Helpers
    private func newTopConstant(translationY: CGFloat) -> CGFloat
    {
        let newConstant = slideyTopConstraint.constant + translationY
        if newConstant > maxTopConstant || newConstant > view.frame.height * 0.5 {
            slideyPosition = .Bottom
            return maxTopConstant
        }
        else {
            slideyPosition = .Top
            return minTopConstant
        }
    }
    
    private var tableViewController: TableViewController!
    private var mapViewController: MapViewController!
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var panGestureRecognizingState: GestureState = .Inactive
    
    @IBOutlet private weak var slideyTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var slideyView: UIView!
    @IBOutlet private weak var backView: UIView!
    
    private var minTopConstant: CGFloat!
    private var maxTopConstant: CGFloat!
    private var beginConstant: CGFloat!
    
    private var slideyPosition = Position.Top {
        didSet {
            
            switch slideyPosition {
            case .Bottom:
                tableViewController.didSnapToBottom()
            case .Top:
                panGestureRecognizingState = .Inactive
                
                tableViewController.didSnapToTop()
            }
        }
    }
}
