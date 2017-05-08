//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

@objc public protocol BackSlideable: class, UIViewControllerProtocol {
    
    var isUserInteractionEnabled: Bool { get set }
    
    @objc optional func bottomOffsetDidChange(_ offset: CGFloat)
}
