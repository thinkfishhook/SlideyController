//
//  ViewController.swift
//  SlideOverMap
//
//  Created by John Hoedeman on 2/6/17.
//  Copyright © 2017 John Hoedeman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var topOfTableView: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewView: TableViewView!
    @IBOutlet weak var mapViewView: MapView!
    
    private var minTopConstant: CGFloat!
    private var maxTopConstant: CGFloat!
    private var beginConstant: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        minTopConstant = view.frame.height * 0.2
        maxTopConstant = view.frame.height * 0.8
        topOfTableView.constant = minTopConstant
        beginConstant = topOfTableView.constant
        
        tableViewView.tableView = tableView
        tableViewView.beginConstant = beginConstant
        self.tableView.delegate = tableViewView
    }
    
    @IBAction func gestureRecognized(_ sender: UIPanGestureRecognizer)
    {
        let translation = sender.translation(in: self.view)
        
        if sender.state == .changed {
            self.topOfTableView.constant = beginConstant + translation.y
        }
        
        if sender.state == .ended {
            UIView.animate(withDuration: 1, animations: {
                self.topOfTableView.constant = self.newTopConstant(translationY: translation.y)
            })
            
            beginConstant = topOfTableView.constant
        }
        
        tableView.isScrollEnabled = topOfTableView.constant == minTopConstant ? true : false
        tableViewView.beginConstant = topOfTableView.constant
    }
    
    private func newTopConstant(translationY: CGFloat) -> CGFloat
    {
        let newConstant = topOfTableView.constant + translationY
        if newConstant > maxTopConstant || newConstant > view.frame.height * 0.5 {
            return maxTopConstant
        }
        else {
            return minTopConstant
        }
    }
}
