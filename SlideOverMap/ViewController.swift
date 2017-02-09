//
//  ViewController.swift
//  SlideOverMap
//
//  Created by John Hoedeman on 2/6/17.
//  Copyright © 2017 John Hoedeman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var slideyTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var slideyView: UIView!
    @IBOutlet weak var backView: UIView!
    
    func setBack(_ back: UIViewController)
    {
        mapViewController = back
        addChildViewController(back)
    }
    
    func setSlidey(_ slidey: UIViewController)
    {
        tableViewController = slidey as! UITableViewController
        addChildViewController(slidey)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        minTopConstant = view.frame.height * 0.2
        maxTopConstant = view.frame.height * 0.8
        slideyTopConstraint.constant = minTopConstant
        beginConstant = slideyTopConstraint.constant
        
        backView.addSubview(mapViewController.view)
        NSLayoutConstraint(item: mapViewController.view, attribute: .top, relatedBy: .equal, toItem: backView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: mapViewController.view, attribute: .leading, relatedBy: .equal, toItem: backView, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: mapViewController.view, attribute: .trailing, relatedBy: .equal, toItem: backView, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: mapViewController.view, attribute: .bottom, relatedBy: .equal, toItem: backView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        slideyView.addSubview(tableViewController.view)
        NSLayoutConstraint(item: tableViewController.view, attribute: .top, relatedBy: .equal, toItem: slideyView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableViewController.view, attribute: .top, relatedBy: .equal, toItem: slideyView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableViewController.view, attribute: .top, relatedBy: .equal, toItem: slideyView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableViewController.view, attribute: .top, relatedBy: .equal, toItem: slideyView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        
        panGestureRecognizer = slideyView.gestureRecognizers?.first as! UIPanGestureRecognizer
        panGestureRecognizer.delegate = self
    }
    
    @IBAction func gestureRecognized(_ sender: UIPanGestureRecognizer)
    {
        print("got here")
        
        
//        let translation = sender.translation(in: self.view)
//        
//        if sender.state == .changed {
//            self.topOfTableView.constant = beginConstant + translation.y
//        }
//        
//        if sender.state == .ended {
//            UIView.animate(withDuration: 1, animations: {
//                self.topOfTableView.constant = self.newTopConstant(translationY: translation.y)
//            })
//            
//            beginConstant = topOfTableView.constant
//        }
//        
//        tableView.isScrollEnabled = topOfTableView.constant == minTopConstant ? true : false
//        tableViewView.beginConstant = topOfTableView.constant
    }
    
    private func newTopConstant(translationY: CGFloat) -> CGFloat
    {
        let newConstant = slideyTopConstraint.constant + translationY
        if newConstant > maxTopConstant || newConstant > view.frame.height * 0.5 {
            return maxTopConstant
        }
        else {
            return minTopConstant
        }
    }
    
    private var tableViewController: UITableViewController!
    private var mapViewController: UIViewController!
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    private var minTopConstant: CGFloat!
    private var maxTopConstant: CGFloat!
    private var beginConstant: CGFloat!
}

extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}

