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
    
    var queryName = ""
    var queryCalories = 0.0
    var queryProteins = 0.0
    var queryGrams = 0.0
    
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
            resetvars()
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
                    if self.queryName != "" {
                        self.queryName = self.queryName + "\\" + item.name
                    }
                    else {
                        self.queryName = item.name
                    }
                    let itemName = NSAttributedString(string: "\n\(item.name)\n", attributes: titleAttributes)
                    let itemDetails = NSAttributedString(string: "Calories: \(item.calories)\nProteins: \(item.proteins)g\nGrams: \(item.grams)g\n", attributes: itemAttributes)
                    resultText.append(itemName)
                    resultText.append(itemDetails)
                }
                self.queryCalories = totalCalories
                self.queryGrams = totalGrams
                self.queryProteins = totalProteins
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
    
    @IBAction func addPressed(_ sender: UIButton) {
        
        let food = FoodItem(name: queryName, calories: queryGrams, proteins: queryCalories, grams: queryProteins)
        
        let alertController = UIAlertController(title: "Add to Meal", message: "Select a meal to add to", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Breakfast", style: .default) { _ in
            self.addToMeal(meal: "Breakfast", foodItem: food)
            self.printFoods(from: "Breakfast")
        })
        alertController.addAction(UIAlertAction(title: "Lunch", style: .default) { _ in
            self.addToMeal(meal: "Lunch", foodItem: food)
        })
        alertController.addAction(UIAlertAction(title: "Dinner", style: .default) { _ in
            self.addToMeal(meal: "Dinner", foodItem: food)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    func addToMeal(meal: String, foodItem: FoodItem) {
        print("Adding \(foodItem.name) to \(meal)")
        
        var meals = getMealsFromFile()
        meals[meal, default: []].append(foodItem)
        
        saveMealsToFile(meals: meals)
    }
    
    func getMealsFromFile() -> [String: [FoodItem]] {
        guard let data = try? Data(contentsOf: mealsFileURL),
              let meals = try? JSONDecoder().decode([String: [FoodItem]].self, from: data) else {
            print("No meals found or couldn't decode the file.")
            return [:]
        }
        return meals
    }
    
    func saveMealsToFile(meals: [String: [FoodItem]]) {
        guard let data = try? JSONEncoder().encode(meals) else { return }
        try? data.write(to: mealsFileURL)
    }
    
    func removeFoodItemFromMeal(meal: String, foodItem: FoodItem) {
        var meals = getMealsFromFile()
        
        // Filter out the specified food item
        meals[meal] = meals[meal]?.filter { $0 != foodItem }
        
        saveMealsToFile(meals: meals)
    }
    
    var mealsFileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent("meals.json")
    }
    
    func printFoods(from meal: String) {
        let meals = getMealsFromFile()
        
        guard let foods = meals[meal] else {
            print("No foods found for \(meal)")
            return
        }
        
        for food in foods {
            print("Name: \(food.name), Calories: \(food.calories), Proteins: \(food.proteins), Grams: \(food.grams)")
        }
    }
    
    func clearMealsFile() {
        let emptyMeals: [String: [FoodItem]] = [:]
        
        saveMealsToFile(meals: emptyMeals)
    }
    
    
    func resetvars() {
        queryName = ""
        queryCalories = 0.0
        queryProteins = 0.0
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
