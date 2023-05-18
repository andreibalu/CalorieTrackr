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

    private var foodService: FoodService!
    private var foodItems = [FoodItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        foodService = FoodService()
        foodTextField.delegate = self
    }

    func searchFoodItems(_ query: String) {
        foodService.searchFoodItems(query: query) { [weak self] result in
            switch result {
            case .success(let items):
                let type = self?.foodSegmentedControl.selectedSegmentIndex == 0 ? "common" : "branded"
                let filteredItems = items.filter { $0.type == type }
                print("Results for \(query) :")
                filteredItems.prefix(5).forEach {
                    print($0.name)
                }
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
