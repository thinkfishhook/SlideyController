//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit
import SlideyController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool
    {
        let rootViewController = window?.rootViewController as! SlideyController
        let storyboard = rootViewController.storyboard
        
        let mapViewController = storyboard?.instantiateViewControllerWithIdentifier("Map View Controller") as! MapViewController
        let tableViewController = storyboard?.instantiateViewControllerWithIdentifier("Table View Controller") as! TableViewController
        
        rootViewController.backViewController = mapViewController
        rootViewController.slideableViewController = tableViewController
        
        return true
    }
}

