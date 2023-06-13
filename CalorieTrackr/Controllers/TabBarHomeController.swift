//
//  TabBarHomeController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 11.05.2023.
//

import UIKit

class TabBarHomeController: UITabBarController, TabBarDelegate{
    func logoutAndNavigateToWelcome() {
        self.tabBar.isUserInteractionEnabled = false
        //Go to WelcomeVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let welcomeViewController = storyboard.instantiateViewController(withIdentifier: K.logout) as? WelcomeViewController {
            let navController = UINavigationController(rootViewController: welcomeViewController)
            navController.modalPresentationStyle = .fullScreen

            // Replace the current view controllers with the welcome view controller
            self.navigationController?.setViewControllers([welcomeViewController], animated: true)
        }
    }
    
    @IBInspectable var initialIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = initialIndex
        navigationItem.hidesBackButton = true
        
        // Set self as the delegate for the ProfileVC after finding it
        guard let viewControllers = viewControllers else { return }
        for viewController in viewControllers {
            if let navController = viewController as? UINavigationController {
                for childViewController in navController.viewControllers {
                    if let SettingsViewController = childViewController as? SettingsViewController {
                        SettingsViewController.tabBarDelegate = self
                    }
                }
            }
        }
    }
}
