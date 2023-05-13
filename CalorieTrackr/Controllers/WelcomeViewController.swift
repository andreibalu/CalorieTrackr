//
//  ViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 22.04.2023.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = ""
        var char = 0.0
        for letter in K.appName {
            Timer.scheduledTimer(withTimeInterval: 0.1 * char, repeats: false) { Timer in
                self.titleLabel.text?.append(letter)
                
                let labelAnimation = CATransition()
                labelAnimation.duration = 0.3
                labelAnimation.type = CATransitionType.fade
                self.titleLabel.layer.add(labelAnimation, forKey: nil)
            }
            char += 1
        }
    }
}

