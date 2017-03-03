//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import Foundation

extension CGPoint {
    
    func offset(by initialTranslation: CGPoint) -> CGPoint
    {
        return CGPoint(x: x - initialTranslation.x, y: y - initialTranslation.y)
    }
}
