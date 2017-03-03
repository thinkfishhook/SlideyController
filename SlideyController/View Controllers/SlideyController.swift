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
        
        dimmingView.alpha = 0
        dimmingView.backgroundColor = UIColor.blackColor()
        backView.addEquallyPinnedSubview(dimmingView)
    }
    
    public override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        setConstants(view.frame.size)
        
        backViewController?.bottomOffsetDidChange?(minTopConstraintConstant)
        slideyTopConstraint.constant = maxTopConstraintConstant
        relativeAlpha = 1 - (slideyTopConstraint.constant / view.frame.height)
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
        setConstants(size)
        
        backViewController?.bottomOffsetDidChange?(minTopConstraintConstant)
        
        switch slideyPosition {
        case .Top:
            slideyTopConstraint.constant = minTopConstraintConstant
            
        case .Bottom:
            slideyTopConstraint.constant = maxTopConstraintConstant
        }
    }
    
    private var panGestureRecognizingState: GestureState = .Active
    
    @IBOutlet private weak var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet private weak var slideyTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var slideyView: UIView! {
        didSet {
            slideyView.addDropShadow()
        }
    }
    
    private var dimmingView = UIView()
    private var positiveHeightRatio: Bool = true
    private var minTopConstraintConstant: CGFloat = 0.0
    private var maxTopConstraintConstant: CGFloat = 0.0
    private var initialTopConstraintConstant: CGFloat = 0.0
    private var relativeAlpha: CGFloat = 0.0
    
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
            panGestureRecognizingState = .Active
        }
        
        if sender.state == .Began {
            initialTopConstraintConstant = slideyTopConstraint.constant
        }
        
        guard panGestureRecognizingState == .Active else { return }
        
        adjustConstraints(sender.state, translation: sender.translationInView(view), velocity: sender.velocityInView(view))
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
    
    func adjustConstraints(_ state: UIGestureRecognizerState, translation: CGPoint, velocity: CGPoint)
    {
        let newTopConstraintConstant = calculateTopConstraintConstant(from: translation.y)
        
        switch state {
        case .Changed:
            
            slideyTopConstraint.constant = newTopConstraintConstant
            
        case .Ended:
            snapToPosition(calculatePosition(from: newTopConstraintConstant, with: velocity.y))
            
        default:
            break
        }
    }
    
    func calculatePosition(from topConstraintConstant: CGFloat, with verticalVelocity: CGFloat = 0.0) -> Position
    {
        if topConstraintConstant + verticalVelocity * 0.5 > maxTopConstraintConstant * 0.51 {
            return .Bottom
        }
        else {
            return .Top
        }
    }
    
    func calculateTopConstraintConstant(from yTranslation: CGFloat) -> CGFloat
    {
        let newConstant = yTranslation + initialTopConstraintConstant
        
        if newConstant >= maxTopConstraintConstant {
            return maxTopConstraintConstant
        }
        else if newConstant <= minTopConstraintConstant {
            return minTopConstraintConstant
        }
        
        return newConstant
    }
    
    func setConstants(size: CGSize)
    {
        positiveHeightRatio = size.height > size.width
        minTopConstraintConstant = positiveHeightRatio ? size.height * 0.2 : size.height * 0.1
        maxTopConstraintConstant = positiveHeightRatio ? size.height * 0.6 : size.height * 0.55
    }
    
    func snapToPosition(newPosition: Position, animated: Bool = true)
    {
        let constant = newPosition == .Top ? minTopConstraintConstant : maxTopConstraintConstant
        
        UIView.animateWithDuration(0.333,
                                   delay: 0,
                                   options: .BeginFromCurrentState,
                                   animations: {
                                    self.slideyTopConstraint.constant = constant
                                    self.view.layoutIfNeeded()
            },
                                   completion: { _ in
                                    self.slideyPosition = newPosition
        })
    }
}
