//
//  AppDelegate.swift
//  SlideOverMap
//
//  Created by John Hoedeman on 2/6/17.
//  Copyright © 2017 John Hoedeman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let rootViewController = self.window?.rootViewController as! ViewController
        let storyboard = rootViewController.storyboard
        
        let mapViewController = storyboard?.instantiateViewController(withIdentifier: "Map View Controller") as! MapViewController
        let tableViewController = storyboard?.instantiateViewController(withIdentifier: "Table View Controller") as! TableViewController
        
        rootViewController.setBack(mapViewController)
        rootViewController.setSlidey(tableViewController)
        
        return true
    }
}

