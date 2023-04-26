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
    var age : String?
    var height : String?
    var weight : String?
    var ideal : String?
    var weeks : String?
    var ex : String?
    var streak : String?
    
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var questionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        navigationItem.hidesBackButton = true
//        pickerViewSex.isHidden = true
//        nameField.isHidden = true
//        progressButton.isHidden = true
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
    
    func hideUI(){
        pickerView.isHidden = true
        nameField.isHidden = true
        backButton.isHidden = true
        nextButton.isHidden = true
        progressButton.isHidden = true
        
    }
    
    func updateUI() {
        hideUI()
        questionLogic()
        buttonLogic()
        
    }
    
    func questionLogic(){
        questionLabel.text = questionsBrain.getQuestionQ()
        if questionsBrain.getQuestionQ() == questionsBrain.questions[0].q {
                       nameField.isHidden = false
                       name = nameField.text       //set name
                   }
        else {
            pickerView.isHidden = false
            pickerView.reloadAllComponents()
        }
    }
    
    func buttonLogic(){
        if questionsBrain.getQuestionNumber() == 0 {
            nextButton.isHidden = false
        }
        else if questionsBrain.getQuestionNumber() == questionsBrain.QuestionsCount - 1 {
            progressButton.isHidden = false
            backButton.isHidden = false
            print(name!)
            print(sex!)
        }
        else {
            backButton.isHidden = false
            nextButton.isHidden = false
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
        let currQ = questionsBrain.getQuestionQ()
        switch currQ {
        case questionsBrain.questions[1].q:
            return questionsBrain.sex.count
        case questionsBrain.questions[2].q:
            return questionsBrain.age.count
        case questionsBrain.questions[3].q:
            return questionsBrain.height.count
        case questionsBrain.questions[4].q:
            return questionsBrain.weight.count
        case questionsBrain.questions[5].q:
            return questionsBrain.ideal.count
        case questionsBrain.questions[6].q:
            return questionsBrain.weeks.count
        case questionsBrain.questions[7].q:
            return questionsBrain.ex.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let currQ = questionsBrain.getQuestionQ()
        switch currQ {
        case questionsBrain.questions[1].q:
            return questionsBrain.sex[row]
        case questionsBrain.questions[2].q:
            return questionsBrain.age[row]
        case questionsBrain.questions[3].q:
            return questionsBrain.height[row]
        case questionsBrain.questions[4].q:
            return questionsBrain.weight[row]
        case questionsBrain.questions[5].q:
            return questionsBrain.ideal[row]
        case questionsBrain.questions[6].q:
            return questionsBrain.weeks[row]
        case questionsBrain.questions[7].q:
            return questionsBrain.ex[row]
        default:
            return "error"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currQ = questionsBrain.getQuestionQ()
        switch currQ {
        case questionsBrain.questions[1].q:
            sex = questionsBrain.sex[row]
        case questionsBrain.questions[2].q:
            age = questionsBrain.age[row]
        case questionsBrain.questions[3].q:
            height = questionsBrain.height[row]
        case questionsBrain.questions[4].q:
            weight = questionsBrain.weight[row]
        case questionsBrain.questions[5].q:
            ideal = questionsBrain.ideal[row]
        case questionsBrain.questions[6].q:
            weeks = questionsBrain.weeks[row]
        case questionsBrain.questions[7].q:
            ex = questionsBrain.ex[row]
        default:
            print("error")
        }      //set sex
    }
}

extension SurveyViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
