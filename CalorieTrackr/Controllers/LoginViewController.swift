//
//  LoginViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 22.04.2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        //
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let pass = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: pass) {authResult, error in
                if let e = error {
                    print(e.localizedDescription)  // add alert system for errors
                } else {
                    self.performSegue(withIdentifier: K.loginSegue, sender: self)     // add alert for successful login
                }
            }
        }
    }
}
