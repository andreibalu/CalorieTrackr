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
        print("dick")
        //Go to WelcomeVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        print("dick")
        if let welcomeViewController = storyboard.instantiateViewController(withIdentifier: K.logout) as? WelcomeViewController {
            print("dick")
            let navController = UINavigationController(rootViewController: welcomeViewController)
            print("dick")
            navController.modalPresentationStyle = .fullScreen
            print("dick")

            // Replace the current view controllers with the welcome view controller
            self.navigationController?.setViewControllers([welcomeViewController], animated: true)
            print("dick")
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
                    if let ProfileViewController = childViewController as? ProfileViewController {
                        ProfileViewController.tabBarDelegate = self
                    }
                }
            }
        }
    }
}
