//
//  Copyright © 2017 Fish Hook LLC. All rights reserved.
//

import UIKit
import SlideyController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool
    {
        let storyboard = window?.rootViewController?.storyboard
        
        let rootViewController = storyboard?.instantiateViewController(withIdentifier: "SlideyController") as! SlideyController
        let mapViewController = storyboard?.instantiateViewController(withIdentifier: "Map View Controller") as! MapViewController
        let tableViewController = storyboard?.instantiateViewController(withIdentifier: "Table View Controller") as! TableViewController
        
        window?.rootViewController = rootViewController
        
        rootViewController.backViewController = mapViewController
        rootViewController.slideableViewController = tableViewController
        
        return true
    }
}

