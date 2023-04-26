//
//  RegisterViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 22.04.2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        passwordTextField.delegate = self
        emailTextField.delegate = self

    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let pass = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: pass) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)   //add alerts ca sa explici de ce nu merge sa faci cont
                } else {
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)    //also add alert for account created sucessfully
                }
        }
        
          
        }
    }
}

extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
