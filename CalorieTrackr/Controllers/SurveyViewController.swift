//
//  SurveyViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 23.04.2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class SurveyViewController: UIViewController {
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    var questionsBrain = QuestionsBrain()
    
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var questionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        
        navigationItem.hidesBackButton = true
        pickerView.isHidden = true
        textField.isHidden = true
        progressButton.isHidden = true

        updateUI()
    }
    
    
    
    @IBAction func backPressed(_ sender: UIButton) {
        if questionsBrain.getQuestionNumber()>0 {
            questionsBrain.prevQuestion()
        }
        updateUI()
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        questionsBrain.nextQuestion()
        updateUI()
    }
    
    func updateUI() {
        questionLabel.text = questionsBrain.getQuestionQ()
        if questionsBrain.getQuestionNeeds() == "TextField" {
            textField.isHidden = false
            pickerView.isHidden = true
        }
        
        if questionsBrain.getQuestionNeeds() == "PickerView" {
            pickerView.isHidden = false
            textField.isHidden = true
        }
        
        if questionsBrain.getQuestionNumber() == 0 {
            backButton.isHidden = true
        }
        else if questionsBrain.getQuestionNumber() == questionsBrain.QuestionsCount - 1 {
            nextButton.isHidden = true
            nextButton.isEnabled = false
            progressButton.isHidden = false
        }
        else {
            backButton.isHidden = false
            nextButton.isHidden = false
            progressButton.isHidden = true
        }
        
        print(questionsBrain.QuestionsCount)
        print(questionsBrain.getQuestionNumber())
//        if questionsBrain
    }
    
    @IBAction func progressPressed(_ sender: Any) {
        
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}




extension SurveyViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
