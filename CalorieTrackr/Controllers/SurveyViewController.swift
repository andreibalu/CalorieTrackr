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
    var height: String?
    var weight : String?
    var ideal : String?
    var weeks : String?
    var ex : String?
    var streak = "0"
    var target = "0"
    
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
        updateUI()
    }
    
    
    
    @IBAction func backPressed(_ sender: UIButton) {
        if questionsBrain.getQuestionNumber()>0 {
            questionsBrain.prevQuestion()
        }
        updateUI()
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        let currQ = questionsBrain.getQuestionQ()
        switch currQ {
        case questionsBrain.questions[0].q:
            name = nameField.text
            print(name!)
        case questionsBrain.questions[1].q:
            sex = questionsBrain.sex[pickerView.selectedRow(inComponent: 0)]
            if sex == "" {
                self.showAlert(title: "Error", message: "Select an option.")
                print("selected no sex")
                questionsBrain.prevQuestion()
            }
            print(sex!)
        case questionsBrain.questions[2].q:
            age = questionsBrain.age[pickerView.selectedRow(inComponent: 0)]
            print(age!)
        case questionsBrain.questions[3].q:
            height = questionsBrain.height[pickerView.selectedRow(inComponent: 0)]
            print(height!)
        case questionsBrain.questions[4].q:
            weight = questionsBrain.weight[pickerView.selectedRow(inComponent: 0)]
            print(weight!)
        case questionsBrain.questions[5].q:
            ideal = questionsBrain.ideal[pickerView.selectedRow(inComponent: 0)]
            print(ideal!)
        case questionsBrain.questions[6].q:
            weeks = questionsBrain.weeks[pickerView.selectedRow(inComponent: 0)]
            print(weeks!)
        case questionsBrain.questions[7].q:
            ex = questionsBrain.ex[pickerView.selectedRow(inComponent: 0)]
            print(ex!)
        default:
            print("error at preselecting")
        }
        
        questionsBrain.nextQuestion()
        updateUI()
    }
    
    @IBAction func progressPressed(_ sender: Any) {
        
        if questionsBrain.getQuestionQ() == questionsBrain.questions[7].q {
            ex = questionsBrain.ex[pickerView.selectedRow(inComponent: 0)]
            print(ex!)
        }

        if let name=name, let sex=sex, let age=age, let height=height, let weight=weight, let ideal=ideal, let weeks=weeks, let ex=ex, let uid = Auth.auth().currentUser?.email {
            let target = BmiBrain(sex: sex, age: age, height: height, weight: weight, ideal: ideal, weeks: weeks, ex: ex).getTarget()
            let docRef = db.collection(K.FStore.collectionName).document(uid)
            docRef.setData([
                K.FStore.senderField: uid,
                K.FStore.name: name,
                K.FStore.sex: sex,
                K.FStore.age: age,
                K.FStore.height: height,
                K.FStore.weight: weight,
                K.FStore.ideal: ideal,
                K.FStore.weeks: weeks,
                K.FStore.ex: ex,
                K.FStore.streak: streak,
                K.FStore.target: target,
                K.FStore.dateField: Date().timeIntervalSince1970
            ], merge: true) { error in
                if let e = error {
                    self.showAlert(title: "Error", message: "There was an issue saving data to firestore, \(e.localizedDescription)")
                } else {
                    let alertController = UIAlertController(title: "Your target will be \(target) calories.", message: "Are you sure you want to continue?", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Go back", style: .cancel, handler: nil)
                    let confirmAction = UIAlertAction(title: "Proceed", style: .destructive) { (_) in
                        do {
                            self.performSegue(withIdentifier: "segueStory", sender: self)
                        }
                    }
                    alertController.addAction(cancelAction)
                    alertController.addAction(confirmAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            }
        }
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
        }
    }
    
    func selectPickerViewRow() {
        let defaultRow = getDefaultPickerViewRow()
        pickerView.selectRow(defaultRow, inComponent: 0, animated: false)
    }
    
    func getDefaultPickerViewRow() -> Int {
        switch questionsBrain.getQuestionQ() {
        case questionsBrain.questions[1].q:
            return 0
        case questionsBrain.questions[2].q:
            return 17
        case questionsBrain.questions[3].q:
            return 50
        case questionsBrain.questions[4].q:
            return 50
        case questionsBrain.questions[5].q:
            return 50
        case questionsBrain.questions[6].q:
            return 5
        case questionsBrain.questions[7].q:
            return 0
        default:
            return 0
        }
    }
    
    func updateUI() {
        hideUI()
        questionLogic()
        buttonLogic()
    }
    
    func hideUI(){
        pickerView.isHidden = true
        nameField.isHidden = true
        backButton.isHidden = true
        nextButton.isHidden = true
        progressButton.isHidden = true
    }
    
    func questionLogic(){
        questionLabel.text = questionsBrain.getQuestionQ()
        if questionsBrain.getQuestionQ() == questionsBrain.questions[0].q {
            nameField.isHidden = false
            name = nameField.text       //set name
        }
        else {
            pickerView.reloadAllComponents()
            selectPickerViewRow()
            pickerView.isHidden = false
            pickerView.reloadAllComponents()
        }
    }
    
    func buttonLogic(){
        let isFirstQuestion = questionsBrain.getQuestionNumber() == 0
        let isLastQuestion = questionsBrain.getQuestionNumber() == questionsBrain.QuestionsCount-1
        
        nextButton.isHidden = isLastQuestion
        progressButton.isHidden = !isLastQuestion
        backButton.isHidden = isFirstQuestion
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension SurveyViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
