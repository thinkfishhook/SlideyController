//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit
import SlideyController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let rootViewController = self.window?.rootViewController as! SlideyController
        let storyboard = rootViewController.storyboard
        
        let mapViewController = storyboard?.instantiateViewController(withIdentifier: "Map View Controller") as! MapViewController
        let tableViewController = storyboard?.instantiateViewController(withIdentifier: "Table View Controller") as! TableViewController
        
        rootViewController.setBack(mapViewController)
        rootViewController.setFront(tableViewController)
        
        return true
    }
}

