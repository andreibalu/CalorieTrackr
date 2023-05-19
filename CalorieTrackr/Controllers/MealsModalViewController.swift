//
//  MealsModalViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 19.05.2023.
//
import UIKit

class MealsModalViewController: UIViewController {
    
    @IBOutlet weak var foodTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!
    
    private var foodService: FoodService!
    private var foodItems = [FoodItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodService = FoodService()
        foodTextField.delegate = self
        resultTextView.text = ""
        resultTextView.clearsOnInsertion = true
        resultTextView.isEditable = false
    }
    
    func searchFoodItems(_ query: String) {
        var totalCalories = 0.0
        var totalProteins = 0.0
        var totalGrams = 0.0
        
        foodService.searchFoodItems(query: query) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let items):
                let resultText = NSMutableAttributedString()
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 18),
                    .foregroundColor: UIColor.black
                ]
                let itemAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.darkGray
                ]
                resultText.append(NSAttributedString(string: "Results for \(query) :\n", attributes: titleAttributes))
                items.forEach { item in
                    totalCalories += item.calories
                    totalProteins += item.proteins
                    totalGrams += item.grams
                    let itemName = NSAttributedString(string: "\n\(item.name)\n", attributes: titleAttributes)
                    let itemDetails = NSAttributedString(string: "Calories: \(item.calories)\nProteins: \(item.proteins)g\nGrams: \(item.grams)g\n", attributes: itemAttributes)
                    resultText.append(itemName)
                    resultText.append(itemDetails)
                }
                let totalTitle = NSAttributedString(string: "\nTotal:\n", attributes: titleAttributes)
                let totalDetails = NSAttributedString(string: "Calories: \(totalCalories)\nProteins: \(totalProteins)g\nGrams: \(totalGrams)g", attributes: itemAttributes)
                resultText.append(totalTitle)
                resultText.append(totalDetails)
                DispatchQueue.main.async {
                    self.resultTextView.attributedText = resultText
                    UIView.transition(with: self.resultTextView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        self.resultTextView.attributedText = resultText
                    }, completion: nil)
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.resultTextView.text = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

extension MealsModalViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            searchFoodItems(text)
        }
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
