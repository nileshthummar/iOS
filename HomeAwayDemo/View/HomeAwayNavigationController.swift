//
//  HomeAwayNavigationController.swift
//  HomeAwayDemo
//
//  Created by Nilesh on 6/2/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class HomeAwayNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: - Navigation bar
    fileprivate func setupNavBar() {
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationBar.backgroundColor = .white
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = UIColor.rgb(r: 15, g: 49, b: 74)
    }
}
