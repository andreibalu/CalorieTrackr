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
    
    var queryName = ""
    var queryCalories = 0.0
    var queryProteins = 0.0
    var queryCarbs = 0.0
    var queryFats = 0.0
    var queryGrams = 0.0
    var queryID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodService = FoodService()
        foodTextField.delegate = self
        resultTextView.text = ""
        resultTextView.clearsOnInsertion = true
        resultTextView.isEditable = false
    }
    
    func searchFoodItems(_ query: String) {
        resetvars()
        foodService.searchFoodItems(query: query) { [weak self] result in
            switch result {
            case .success(let items):
                self?.displaySearchResults(items,query)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.resultTextView.text = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func displaySearchResults(_ items: [FoodItem],_ query: String) {
        var totalCalories = 0.0
        var totalProteins = 0.0
        var totalCarbs = 0.0
        var totalFats = 0.0
        var totalGrams = 0.0
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
            totalCarbs += item.carbs
            totalFats += item.fats
            totalGrams += item.grams
            if self.queryName != "" {
                self.queryName = self.queryName + " + " + item.name
            }
            else {
                self.queryName = item.name
            }
            let itemName = NSAttributedString(string: "\n\(item.name)\n", attributes: titleAttributes)
            let itemDetails = NSAttributedString(string: "Calories: \(Int(item.calories))\nProteins: \(String(format: "%.2f",item.proteins))g\nGrams: \(Int(item.grams))g\n", attributes: itemAttributes)
            resultText.append(itemName)
            resultText.append(itemDetails)
        }
        self.queryCalories = totalCalories
        self.queryGrams = totalGrams
        self.queryProteins = totalProteins
        self.queryCarbs = totalCarbs
        self.queryFats = totalFats
        let totalTitle = NSAttributedString(string: "\nTotal:\n", attributes: titleAttributes)
        let totalDetails = NSAttributedString(string: "Calories: \(Int(totalCalories))\nProteins: \(String(format: "%.2f",totalProteins))g\nGrams: \(Int(totalGrams))g", attributes: itemAttributes)
        resultText.append(totalTitle)
        resultText.append(totalDetails)
        DispatchQueue.main.async {
            self.resultTextView.attributedText = resultText
            UIView.transition(with: self.resultTextView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.resultTextView.attributedText = resultText
            }, completion: nil)
        }

    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        let food = FoodItem(id: UUID(),name: queryName, calories: queryCalories, proteins: queryProteins, carbs: queryCarbs, fats: queryFats, grams: queryGrams)
        if foodTextField.text != ""{
            if food.name != "" {
                presentAddToMealActionSheet(for: food)
            }
            else {
                showAlert(title: "\(foodTextField.text!) doesn't look tasty", message: "Try adding something else")
            }
        }
        else {
            showAlert(title: "Try searching for a food", message: "Something like apples, bananas..")
        }
    }
    
    private func presentAddToMealActionSheet(for foodItem: FoodItem) {
        let alertController = UIAlertController(title: "Add to Meal", message: "Select a meal to add to", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: K.Api.food.breakfast, style: .default) { _ in
            self.foodService.addToMeal(meal: K.Api.food.breakfast, foodItem: foodItem)
        })
        alertController.addAction(UIAlertAction(title: K.Api.food.lunch, style: .default) { _ in
            self.foodService.addToMeal(meal: K.Api.food.lunch, foodItem: foodItem)
        })
        alertController.addAction(UIAlertAction(title: K.Api.food.dinner, style: .default) { _ in
            self.foodService.addToMeal(meal: K.Api.food.dinner, foodItem: foodItem)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func resetvars() {
        queryName = ""
        queryCalories = 0.0
        queryProteins = 0.0
        queryCarbs = 0.0
        queryFats = 0.0
        queryGrams = 0.0
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
