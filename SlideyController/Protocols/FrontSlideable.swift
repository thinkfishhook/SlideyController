//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

public protocol FrontSlideable: class, UIViewControllerProtocol {
    
    var overScrolling: Bool { get set }
    
    func didSnapToBottom()
    func didSnapToTop()
}
