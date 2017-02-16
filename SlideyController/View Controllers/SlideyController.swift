//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit

public class SlideyController: UIViewController {
    
    public var slideableViewController: FrontSlideable? {
        willSet {
            guard let viewController = slideableViewController else { return }
            
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
        }
        didSet {
            guard let viewController = slideableViewController else { return }
            
            addChildViewControllerProtocol(viewController)
            if isViewLoaded() {
                addSlideSubview(viewController.view)
            }
        }
    }
    
    public var backViewController: BackSlideable? {
        willSet {
            guard let viewController = backViewController else { return }
            
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
        }
        didSet {
            guard let viewController = backViewController else { return }
            
            addChildViewControllerProtocol(viewController)
            if isViewLoaded() {
                addBackSubview(viewController.view)
            }
        }
    }
    
    // MARK: View Life Cycle
     
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        minTopConstant = view.frame.height * 0.2
        maxTopConstant = view.frame.height * 0.6
        slideyTopConstraint.constant = maxTopConstant
        beginConstant = slideyTopConstraint.constant
        
        if let view = backViewController?.view {
            addBackSubview(view)
        }
        
        if let view = slideableViewController?.view {
            addSlideSubview(view)
        }
    }
    
    private var panGestureRecognizingState: GestureState = .Active
    
    @IBOutlet private weak var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet private weak var slideyTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var slideyView: UIView!
    @IBOutlet private weak var backView: UIView!
    
    private var minTopConstant: CGFloat = 0.0
    private var maxTopConstant: CGFloat = 0.0
    private var beginConstant: CGFloat = 0.0
    
    private var slideyPosition = Position.Top {
        didSet {
            
            switch slideyPosition {
            case .Bottom:
                slideableViewController?.didSnapToBottom()
                backViewController?.isUserInteractionEnabled = true
                
            case .Top:
                panGestureRecognizingState = .Inactive
                
                slideableViewController?.didSnapToTop()
                backViewController?.isUserInteractionEnabled = false
            }
        }
    }
    
    private enum Position {
        case Bottom
        case Top
    }
    
    private enum GestureState {
        case Active
        case Inactive
    }
}

// MARK: Interface Builder Actions
extension SlideyController {
    
    @IBAction func gestureRecognized(_ sender: UIPanGestureRecognizer)
    {
        if panGestureRecognizingState == .Inactive && slideableViewController?.overScrolling == true  {
            panGestureRecognizingState = .Active
        }
        
        guard panGestureRecognizingState == .Active else { return }
        
        adjustConstraints(sender, translation: sender.translationInView(self.view))
    }
}

// MARK: Gesture Recognizer Delegate
extension SlideyController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}

// MARK: Private Helpers
private extension SlideyController {
    
    func addBackSubview(_ view: UIView)
    {
        backView.addEquallyPinnedSubview(view)
    }
    
    func addSlideSubview(_ view: UIView)
    {
        slideyView.addEquallyPinnedSubview(view)
    }
    
    func adjustConstraints(_ recognizer: UIGestureRecognizer, translation: CGPoint)
    {
        guard let tableViewController = slideableViewController as? UITableViewController else { return }
        
        switch recognizer.state {
        case .Changed:
            slideyTopConstraint.constant = beginConstant + translation.y
            tableViewController.tableView.scrollEnabled = false
        case .Ended:
            view.layoutIfNeeded()
            UIView.animateWithDuration(0.5, animations: {
                self.slideyTopConstraint.constant = self.newTopConstant(translation.y)
                self.view.layoutIfNeeded()
            })
            tableViewController.tableView.scrollEnabled = true
            beginConstant = slideyTopConstraint.constant
        default:
            break
        }
    }
    
    func newTopConstant(_ translationY: CGFloat) -> CGFloat
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
}
