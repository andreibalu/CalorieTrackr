//
//  MealsViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 18.05.2023.
//

import UIKit

class MealsViewController: UIViewController {
    @IBOutlet weak var foodTextField: UITextField!
    @IBOutlet weak var foodSegmentedControl: UISegmentedControl!
    
    var lastCalories: Double?

    private var foodService: FoodService!
    private var foodItems = [FoodItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        foodService = FoodService()
        foodTextField.delegate = self
    }

    func searchFoodItems(_ query: String) {
        var totalCalories = 0.0
        var totalProteins = 0.0
        var totalGrams = 0.0

        foodService.searchFoodItems(query: query) { [weak self] result in
            switch result {
            case .success(let items):
                print("Results for \(query) :")
                items.forEach { item in
                    totalCalories += item.calories
                    totalProteins += item.proteins
                    totalGrams += item.grams
                    print("\(item.name): \(item.calories) calories")
                    print("\(item.name): \(item.proteins) proteins")
                    print("\(item.name): \(item.grams) grams")
                }
                print("Total calories for all items: \(totalCalories)")
                print("Total proteins for all items: \(totalProteins)")
                print("Total grams for all items: \(totalGrams)")
            case .failure(let error):
                print(error)
            }
        }
    }

}

extension MealsViewController: UITextFieldDelegate {
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
