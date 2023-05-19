//
//  MealsViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 18.05.2023.
//

import UIKit

class MealsViewController: UIViewController {

    private var foodService: FoodService!
    private var foodItems = [FoodItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        foodService = FoodService()
    }
}

