//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit
import MapKit
import SlideyController

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
}

extension MapViewController: SlideyBackType {
    
    var isUserInteractionEnabled: Bool {
        get {
            return mapView.isUserInteractionEnabled
        }
        set {
            mapView.isUserInteractionEnabled = newValue
        }
    }
}
