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
    
    var questionsBrain = QuestionsBrain()
    var name : String?
    var sex : String?
    var age : Int?
    var height : Int?
    var weight : Double?
    var weightGoal : Double?
    var weeksGoal : Int?
    var activity : Int?
    var streak : Int?
    
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var pickerViewSex: UIPickerView!
    @IBOutlet weak var questionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        
        pickerViewSex.dataSource = self
        pickerViewSex.delegate = self
        
        navigationItem.hidesBackButton = true
        pickerViewSex.isHidden = true
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
        if questionsBrain.getQuestionNeeds() == "textField" {
            textField.isHidden = false
            pickerViewSex.isHidden = true
            name = textField.text       //set name
        }
        
        if questionsBrain.getQuestionNeeds() == "pickerViewSex" {
            pickerViewSex.isHidden = false
            textField.isHidden = true
        }
        
        if questionsBrain.getQuestionNeeds() == "pickerView" {
            pickerViewSex.isHidden = true
            textField.isHidden = true
        }
        
        if questionsBrain.getQuestionNumber() == 0 {
            backButton.isHidden = true
        }
        else if questionsBrain.getQuestionNumber() == questionsBrain.QuestionsCount - 1 {
            nextButton.isHidden = true
            progressButton.isHidden = false
            print(name!)
            print(sex!)
        }
        else {
            backButton.isHidden = false
            nextButton.isHidden = false
            progressButton.isHidden = true
        }
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

extension SurveyViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return questionsBrain.sex.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return questionsBrain.sex[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sex = questionsBrain.sex[row]       //set sex
    }
}

extension SurveyViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
