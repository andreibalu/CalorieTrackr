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
        
        passwordTextField.delegate = self
        emailTextField.delegate = self
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let pass = passwordTextField.text {
            if email.isEmpty, pass.isEmpty {
                showAlert(title: "Error", message: "Please fill in all fields.")
                return
            }
            
            if !isValidEmail(email) {
                showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
                return
            }
            
            if pass.count < 6 {
                showAlert(title: "Password Too Short", message: "Password must be at least 6 characters long.")
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: pass) { authResult, error in
                if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                    switch errorCode {
                    case .emailAlreadyInUse:
                        self.showAlert(title: "Email Already in Use", message: "This email is already associated with an account. Please use a different email.")
                    case .invalidEmail:
                        self.showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
                    default:
                        self.showAlert(title: "Registration Error", message: "An error occurred while trying to create your account. Please try again later.")
                    }
                } else {
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
                }
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
