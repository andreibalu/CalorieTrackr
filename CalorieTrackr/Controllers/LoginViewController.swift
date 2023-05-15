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
        
        passwordTextField.delegate = self
        emailTextField.delegate = self
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let pass = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty, !pass.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        if !isValidEmail(email) {
            showAlert(title: "Error", message: "Please enter a valid email address.")
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            Auth.auth().signIn(withEmail: email, password: pass) { authResult, error in
                if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                    switch errorCode {
                    case .invalidEmail:
                        self.showAlert(title: "Error", message: "Invalid email address.")
                    case .wrongPassword:
                        self.showAlert(title: "Error", message: "Wrong password.")
                    case .userDisabled:
                        self.showAlert(title: "Error", message: "This user has been disabled.")
                    case .userNotFound:
                        self.showAlert(title: "Error", message: "User not found.")
                    case .internalError:
                        self.showAlert(title: "Error", message: "An internal error has occured.")
                    default:
                        self.showAlert(title: "Error", message: "An unknown error occurred.")
                    }
                } else {
                    // self.performSegue(withIdentifier: K.loginSegue, sender: self)
                    print("sign in success")
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
        self.present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
