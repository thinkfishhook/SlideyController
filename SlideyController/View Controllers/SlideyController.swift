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
                slideyPosition == .Bottom ? viewController.didSnapToBottom() : viewController.didSnapToTop()
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
                slideyPosition == .Bottom ? viewController.bottomOffsetDidChange?(minTopConstraintConstant) : viewController.bottomOffsetDidChange?(maxTopConstraintConstant)
            }
        }
    }
    
    // MARK: View Life Cycle
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let view = backViewController?.view {
            addBackSubview(view)
            slideyPosition == .Bottom ? backViewController?.bottomOffsetDidChange?(minTopConstraintConstant) : backViewController?.bottomOffsetDidChange?(maxTopConstraintConstant)
        }
        
        if let view = slideableViewController?.view {
            addSlideSubview(view)
            slideyPosition == .Bottom ? slideableViewController?.didSnapToBottom() : slideableViewController?.didSnapToTop()
        }
        
        dimmingView.alpha = 0
        dimmingView.backgroundColor = UIColor.blackColor()
        backView.addEquallyPinnedSubview(dimmingView)
    }
    
    public override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        setConstants(view.frame.size)
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
    
    private var minTopConstraintConstant: CGFloat = 0.0
    private var maxTopConstraintConstant: CGFloat = 0.0
    private var initialTopConstraintConstant: CGFloat = 0.0
    private var initialTranslation = CGPointZero
    
    private var slideyPosition = Position.Bottom {
        didSet {
            
            switch (oldValue, slideyPosition) {
            case (.Top, .Bottom):
                slideableViewController?.didSnapToBottom()
                backViewController?.bottomOffsetDidChange?(minTopConstraintConstant)
                backViewController?.isUserInteractionEnabled = true
                
            case (.Bottom, .Top):
                panGestureRecognizingState = .Inactive
                
                slideableViewController?.didSnapToTop()
                backViewController?.isUserInteractionEnabled = false
                
            case (_, .Top):
                panGestureRecognizingState = .Inactive
                
            default:
                break
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
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        if panGestureRecognizingState == .Inactive && slideableViewController?.overScrolling == true  {
            panGestureRecognizingState = .Active
            initialTranslation = sender.translationInView(view)
        }
        
        let offsetPoint = translation.offset(by: initialTranslation)
        
        if sender.state == .Began {
            initialTopConstraintConstant = slideyTopConstraint.constant
        }
        else if sender.state == .Ended && panGestureRecognizingState == .Active {
            snapToPosition(calculatePosition(from: calculateTopConstraintConstant(from: offsetPoint.y), with: velocity.y))
        }
        else if sender.state == .Changed && panGestureRecognizingState == .Active {
            adjustConstraints(with: offsetPoint)
            adjustDimmingView(with: offsetPoint)
        }
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
    
    func adjustConstraints(with translation: CGPoint)
    {
        slideyTopConstraint.constant = calculateTopConstraintConstant(from: translation.y)
    }
    
    func adjustDimmingView(with translation: CGPoint)
    {
        dimmingView.alpha = calculateAlpha(from: translation.y) / 2.0
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
    
    func calculateAlpha(from yTranslation: CGFloat) -> CGFloat
    {
        // min constraint < calc'd constrant < max constraint
        //    alpha 1.0   <   calc'd alpha   <   alpha 0.0
        
        return 1.0 - (calculateTopConstraintConstant(from: yTranslation) - minTopConstraintConstant) / (maxTopConstraintConstant - minTopConstraintConstant)
    }
    
    func setConstants(size: CGSize)
    {
        let positiveHeightRatio = size.height > size.width
        let newMin = positiveHeightRatio ? size.height * 0.2 : size.height * 0.1
        let newMax = positiveHeightRatio ? size.height * 0.6 : size.height * 0.55
        
        if newMin != minTopConstraintConstant {
            minTopConstraintConstant = newMin
            if slideyPosition == .Top {
                slideyTopConstraint.constant = minTopConstraintConstant
            }
            else if slideyPosition == .Bottom {
                backViewController?.bottomOffsetDidChange?(minTopConstraintConstant)
            }
        }
        
        if newMax != maxTopConstraintConstant {
            maxTopConstraintConstant = newMax
            if slideyPosition == .Bottom {
                slideyTopConstraint.constant = maxTopConstraintConstant
            }
            else if slideyPosition == .Top {
                backViewController?.bottomOffsetDidChange?(maxTopConstraintConstant)
            }
        }
    }
    
    func snapToPosition(newPosition: Position, animated: Bool = true)
    {
        let duration = animated ? 0.333 : 0.0
        let constant = newPosition == .Top ? minTopConstraintConstant : maxTopConstraintConstant
        let alpha: CGFloat = newPosition == .Top ? 0.5 : 0.0
        
        UIView.animateWithDuration(duration,
                                   delay: 0,
                                   options: .BeginFromCurrentState,
                                   animations: {
                                    self.slideyTopConstraint.constant = constant
                                    self.dimmingView.alpha = alpha
                                    self.view.layoutIfNeeded()
            },
                                   completion: { _ in
                                    self.slideyPosition = newPosition
        })
    }
}
