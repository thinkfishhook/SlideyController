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
        
        if let view = backViewController?.view {
            addBackSubview(view)
        }
        
        if let view = slideableViewController?.view {
            addSlideSubview(view)
        }
        
        addDropShadow()
        dimmingView.alpha = 0
        dimmingView.backgroundColor = UIColor.blackColor()
        backView.addEquallyPinnedSubview(dimmingView)
    }
    
    public override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        setConstants(view.frame.size)
        
        backViewController?.bottomOffsetDidChange?(minTopConstant)
        slideyTopConstraint.constant = maxTopConstant
        beginConstant = slideyTopConstraint.constant
        relativeAlpha = 1 - (slideyTopConstraint.constant / view.frame.height)
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
        setConstants(size)
        
        backViewController?.bottomOffsetDidChange?(minTopConstant)
        
        switch slideyPosition {
        case .Top:
            slideyTopConstraint.constant = minTopConstant
            beginConstant = minTopConstant
        case .Bottom:
            slideyTopConstraint.constant = maxTopConstant
            beginConstant = maxTopConstant
        }
    }
    
    private var panGestureRecognizingState: GestureState = .Active
    
    @IBOutlet private weak var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet private weak var slideyTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var slideyView: UIView!
    @IBOutlet private weak var backView: UIView!
    
    private var dimmingView = UIView()
    private var positiveHeightRatio: Bool = true
    private var minTopConstant: CGFloat = 0.0
    private var maxTopConstant: CGFloat = 0.0
    private var beginConstant: CGFloat = 0.0
    private var relativeAlpha: CGFloat = 0.0
    private var tableViewScrollOffset: CGFloat = 0.0
    
    private var slideyPosition = Position.Top {
        didSet {
            
            switch slideyPosition {
            case .Bottom:
                slideableViewController?.didSnapToBottom()
                backViewController?.isUserInteractionEnabled = true
                dimmingView.alpha = 0
                
            case .Top:
                panGestureRecognizingState = .Inactive
                
                slideableViewController?.didSnapToTop()
                backViewController?.isUserInteractionEnabled = false
                dimmingView.alpha = 0.5
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
            tableViewScrollOffset = sender.translationInView(self.view).y
            panGestureRecognizingState = .Active
        }
        
        guard panGestureRecognizingState == .Active else { return }
        
        adjustConstraints(sender.state, translation: sender.translationInView(self.view), tableViewScrollOffset: tableViewScrollOffset)
    }
}

// MARK: Gesture Recognizer Delegate
extension SlideyController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
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
    
    func adjustConstraints(_ state: UIGestureRecognizerState, translation: CGPoint, tableViewScrollOffset: CGFloat)
    {
        guard let tableViewController = slideableViewController as? UITableViewController else { return }
        
        switch state {
        case .Changed:
            tableViewController.tableView.scrollEnabled = false
            
            if beginConstant + translation.y > maxTopConstant {
                animateSnapToNewConstant(tableViewController, translation: translation)
            }
            else if beginConstant + translation.y < minTopConstant {
                animateSnapToNewConstant(tableViewController, translation: translation)
            }
            else {
                slideyTopConstraint.constant = beginConstant + (translation.y - tableViewScrollOffset)
                let computedAlpha = ((1 - (slideyTopConstraint.constant / view.frame.height)) - relativeAlpha)
                if computedAlpha >= 0.5 {
                    dimmingView.alpha = 0.5
                }
                else if computedAlpha <= 0 {
                    dimmingView.alpha = 0
                }
                else {
                    dimmingView.alpha = computedAlpha
                }
            }
            
        case .Ended:
            animateSnapToNewConstant(tableViewController, translation: translation)
            
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
    
    func setConstants(size: CGSize)
    {
        positiveHeightRatio = size.height > size.width ? true : false
        minTopConstant = positiveHeightRatio ? size.height * 0.2 : size.height * 0.1
        maxTopConstant = positiveHeightRatio ? size.height * 0.6 : size.height * 0.55
    }
    
    func addDropShadow()
    {
        slideyView.layer.masksToBounds = false
        slideyView.layer.shadowRadius = 5
        slideyView.layer.shadowColor = UIColor.blackColor().CGColor
        slideyView.layer.shadowOpacity = 0.5
    }
    
    func animateSnapToNewConstant(tableViewController: UITableViewController, translation: CGPoint)
    {
        view.layoutIfNeeded()
        UIView.animateWithDuration(0.333, delay: 0, options: .CurveEaseInOut, animations: {
            self.slideyTopConstraint.constant = self.newTopConstant(translation.y)
            self.view.layoutIfNeeded()
        }, completion: nil)
        tableViewController.tableView.scrollEnabled = true
        beginConstant = slideyTopConstraint.constant
    }
}
