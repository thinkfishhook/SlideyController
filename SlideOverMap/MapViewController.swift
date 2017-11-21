//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit
import MapKit
import SlideyController

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
}

extension MapViewController: BackSlideable {
    
    var isUserInteractionEnabled: Bool {
        get {
            return mapView.isUserInteractionEnabled
        }
        set {
            mapView.isUserInteractionEnabled = newValue
        }
    }
    
    func bottomOffsetDidChange(offset: CGFloat)
    {
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: offset, right: 0)
        mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: edgeInsets, animated: false)
    }
}
