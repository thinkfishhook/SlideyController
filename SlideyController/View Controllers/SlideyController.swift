//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit

public final class SlideyController: UIViewController {
    
    public var slideableViewController: FrontSlideable? {
        willSet {
            guard let viewController = slideableViewController else { return }
            
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
        }
        didSet {
            guard let viewController = slideableViewController else { return }
            
            add(childViewController: viewController)
            if isViewLoaded {
                addSlideSubview(viewController.view)
                slideyPosition == .bottom ? viewController.didSnapToBottom() : viewController.didSnapToTop()
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
            
            add(childViewController: viewController)
            if isViewLoaded {
                addBackSubview(viewController.view)
                slideyPosition == .bottom ? viewController.bottomOffsetDidChange?(minTopConstraintConstant) : viewController.bottomOffsetDidChange?(maxTopConstraintConstant)
            }
        }
    }
    
    // MARK: View Life Cycle
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let view = backViewController?.view {
            addBackSubview(view)
        }
        
        if let view = slideableViewController?.view {
            addSlideSubview(view)
        }
        
        dimmingView.alpha = 0
        dimmingView.backgroundColor = UIColor.black
        backView.addEquallyPinned(subview: dimmingView)
    }
    
    public override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        switch slideyPosition {
        case .bottom:
            slideableViewController?.didSnapToBottom()
        case .top:
            slideableViewController?.didSnapToTop()
        }
        
        updateOffsetsIfNeeded()
    }
    
    public override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()

        setConstants(view.frame.size)
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        setConstants(size)
        
        coordinator.animate(alongsideTransition: nil, completion: { _ in self.updateOffsetsIfNeeded() })
    }
    
    fileprivate var panGestureRecognizingState: GestureState = .active
    
    @IBOutlet private weak var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet fileprivate weak var slideyTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var backView: UIView!
    @IBOutlet fileprivate weak var slideyView: UIView! {
        didSet {
            slideyView.addDropShadow()
        }
    }
    
    fileprivate var dimmingView = UIView()
    
    fileprivate var minTopConstraintConstant: CGFloat = 0.0
    fileprivate var maxTopConstraintConstant: CGFloat = 0.0
    fileprivate var initialTopConstraintConstant: CGFloat = 0.0
    fileprivate var initialTranslation: CGPoint = .zero
    fileprivate var offsetsUpdateNeeded = false
    
    fileprivate var slideyPosition = Position.bottom {
        didSet {
            
            switch (oldValue, slideyPosition) {
            case (.top, .bottom):
                slideableViewController?.didSnapToBottom()
                backViewController?.bottomOffsetDidChange?(slideyView.frame.height)
                backViewController?.isUserInteractionEnabled = true
                
            case (.bottom, .top):
                panGestureRecognizingState = .inactive
                
                slideableViewController?.didSnapToTop()
                backViewController?.bottomOffsetDidChange?(slideyView.frame.height)
                backViewController?.isUserInteractionEnabled = false
                
            case (_, .top):
                panGestureRecognizingState = .inactive
                
            default:
                break
            }
        }
    }
    
    fileprivate enum Position {
        case bottom
        case top
    }
    
    fileprivate enum GestureState {
        case active
        case inactive
    }
}

// MARK: Interface Builder Actions
extension SlideyController {
    
    @IBAction func gestureRecognized(_ sender: UIPanGestureRecognizer)
    {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if panGestureRecognizingState == .inactive && slideableViewController?.overScrolling == true  {
            panGestureRecognizingState = .active
            initialTranslation = sender.translation(in: view)
        }
        
        let offsetPoint = translation.offset(by: initialTranslation)
        
        if sender.state == .began {
            initialTopConstraintConstant = slideyTopConstraint.constant
        }
        else if sender.state == .ended && panGestureRecognizingState == .active {
            snapToPosition(calculatePosition(from: calculateTopConstraintConstant(from: offsetPoint.y), with: velocity.y))
        }
        else if sender.state == .changed && panGestureRecognizingState == .active {
            adjustConstraints(with: offsetPoint)
            adjustDimmingView(with: offsetPoint)
        }
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
        backView.addEquallyPinned(subview: view)
    }
    
    func addSlideSubview(_ view: UIView)
    {
        slideyView.addEquallyPinned(subview: view)
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
            return .bottom
        }
        else {
            return .top
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
    
    func setConstants(_ size: CGSize)
    {
        let positiveHeightRatio = size.height > size.width
        let newMin = positiveHeightRatio ? size.height * 0.2 : size.height * 0.1
        let newMax = positiveHeightRatio ? size.height * 0.6 : size.height * 0.55
        
        if newMin != minTopConstraintConstant {
            minTopConstraintConstant = newMin
            setNeedsOffsetsUpdate()
            if slideyPosition == .top {
                slideyTopConstraint.constant = minTopConstraintConstant
            }
        }
        
        if newMax != maxTopConstraintConstant {
            maxTopConstraintConstant = newMax
            setNeedsOffsetsUpdate()
            if slideyPosition == .bottom {
                slideyTopConstraint.constant = maxTopConstraintConstant
            }
        }
    }
    
    func setNeedsOffsetsUpdate()
    {
        offsetsUpdateNeeded = true
    }
    
    func updateOffsetsIfNeeded()
    {
        // NOTE: It is tempting to DRY up code and only call this method from
        // one place - `viewDidLayoutSubviews()`. However, that is too early to
        // notify child view controllers of the offset change; their views will
        // not have correct frame values.
        //
        // In my mind, the name `didLayoutSubviews()` implies a cascading event
        // has happened in which child view controllers' views have been laid
        // out and their view controller notified of the change.
        // 
        // However, in practice this is not the case.
        
        guard offsetsUpdateNeeded else { return }
        
        backViewController?.bottomOffsetDidChange?(slideyView.frame.height)
        offsetsUpdateNeeded = false
    }
    
    func snapToPosition(_ newPosition: Position, animated: Bool = true)
    {
        let duration = animated ? 0.333 : 0.0
        let constant = newPosition == .top ? minTopConstraintConstant : maxTopConstraintConstant
        let alpha: CGFloat = newPosition == .top ? 0.5 : 0.0
        
        UIView.animate(withDuration: duration,
                                   delay: 0,
                                   options: .beginFromCurrentState,
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
