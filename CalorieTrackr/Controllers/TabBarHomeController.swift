//
//  TabBarHomeController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 11.05.2023.
//

import UIKit

class TabBarHomeController: UITabBarController{
    @IBInspectable var initialIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = initialIndex
        navigationItem.hidesBackButton = true
        
        

    }
}
