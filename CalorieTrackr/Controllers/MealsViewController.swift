//
//  MealsViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 18.05.2023.
//

import UIKit

class MealsViewController: UIViewController {

    private var foodService: FoodService!
//    private var foodItems = [FoodItem]()
    var foodItems1 :[FoodItem] = [
        FoodItem(name: "apple1", calories: 100.0, proteins: 120.0, grams: 130.0),
        FoodItem(name: "banana1", calories: 120.0, proteins: 30.0, grams: 330.0),
        FoodItem(name: "apple1", calories: 100.0, proteins: 120.0, grams: 130.0),
        FoodItem(name: "banana1", calories: 120.0, proteins: 30.0, grams: 330.0)
    ]
    var foodItems2 :[FoodItem] = [
        FoodItem(name: "apple2", calories: 100.0, proteins: 120.0, grams: 130.0),
        FoodItem(name: "banana2", calories: 120.0, proteins: 30.0, grams: 330.0)
    ]
    var foodItems3 :[FoodItem] = [
        FoodItem(name: "apple3", calories: 100.0, proteins: 120.0, grams: 130.0),
        FoodItem(name: "banana3", calories: 120.0, proteins: 30.0, grams: 330.0)
    ]

    @IBOutlet weak var tableViewDinner: UITableView!
    @IBOutlet weak var tableViewLunch: UITableView!
    @IBOutlet weak var tableViewBreak: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodService = FoodService()
        
        tableViewBreak.dataSource = self
        tableViewBreak.backgroundColor = UIColor.clear
        tableViewLunch.dataSource = self
        tableViewLunch.backgroundColor = UIColor.clear
        tableViewDinner.dataSource = self
        tableViewDinner.backgroundColor = UIColor.clear
        
        tableViewBreak.reloadData()
        tableViewLunch.reloadData()
        tableViewDinner.reloadData()
    }
}

extension MealsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewBreak {
            return foodItems1.count
        }
        else if tableView == tableViewLunch {
            return foodItems2.count
        }
        else if tableView == tableViewDinner {
            return foodItems3.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableViewBreak {
            let cell = tableViewBreak.dequeueReusableCell(withIdentifier: "Reuse1" , for: indexPath)
            cell.textLabel?.text = foodItems1[indexPath.row].name + " -> " + String(Int(foodItems1[indexPath.row].calories))
            cell.backgroundColor = UIColor.clear
            return cell
        }
        else if tableView ==  tableViewLunch {
            let cell = tableViewLunch.dequeueReusableCell(withIdentifier: "Reuse2" , for: indexPath)
            cell.textLabel?.text = foodItems2[indexPath.row].name + " -> " + String(Int(foodItems1[indexPath.row].calories))
            cell.backgroundColor = UIColor.clear
            return cell
        }
        else {
            let cell = tableViewDinner.dequeueReusableCell(withIdentifier: "Reuse3" , for: indexPath)
            cell.textLabel?.text = foodItems3[indexPath.row].name + " -> " + String(Int(foodItems1[indexPath.row].calories))
            cell.backgroundColor = UIColor.clear
            return cell
        }
    }
    
    
}
