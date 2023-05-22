//
//  MealsViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 18.05.2023.
//

import UIKit

protocol MealsViewControllerDelegate: AnyObject { //for refreshing tables after adding food to a meal
    func didAddFoodItem()
}


class MealsViewController: UIViewController {
    private var foodService = FoodService()
    
    @IBOutlet weak var tableViewDinner: UITableView!
    @IBOutlet weak var tableViewLunch: UITableView!
    @IBOutlet weak var tableViewBreak: UITableView!
    @IBOutlet weak var totalCalories: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodService = FoodService()
        foodService.delegate = self
        
        setUpTables()
        totalCalories.text = String(Int(self.foodService.getTotalCaloriesFromMealFile()))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableViewBreak.reloadData()
        tableViewLunch.reloadData()
        tableViewDinner.reloadData()
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Deleting all foods registered", message: "Are you sure you want to continue?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Go back", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Proceed", style: .destructive) { (_) in
            do {
                self.foodService.emptyMealsFile()
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setUpTables() {
        tableViewBreak.dataSource = self
        tableViewBreak.delegate = self
        tableViewBreak.backgroundColor = UIColor.clear
        tableViewLunch.dataSource = self
        tableViewLunch.delegate = self
        tableViewLunch.backgroundColor = UIColor.clear
        tableViewDinner.dataSource = self
        tableViewDinner.delegate = self
        tableViewDinner.backgroundColor = UIColor.clear
        
        tableViewBreak.register(UINib(nibName: K.foodCell.cellNibName, bundle: nil), forCellReuseIdentifier: K.foodCell.cellIdentifier)
        tableViewLunch.register(UINib(nibName: K.foodCell.cellNibName, bundle: nil), forCellReuseIdentifier: K.foodCell.cellIdentifier)
        tableViewDinner.register(UINib(nibName: K.foodCell.cellNibName, bundle: nil), forCellReuseIdentifier: K.foodCell.cellIdentifier)
    }
}

extension MealsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewBreak {
            return self.foodService.getFoodsCountFromMeal(meal: K.Api.food.breakfast)
        }
        else if tableView == tableViewLunch {
            return self.foodService.getFoodsCountFromMeal(meal: K.Api.food.lunch)
        }
        else if tableView == tableViewDinner {
            return self.foodService.getFoodsCountFromMeal(meal: K.Api.food.dinner)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableViewBreak {
            let cell = tableViewBreak.dequeueReusableCell(withIdentifier: K.foodCell.cellIdentifier, for: indexPath) as! FoodCell
            let food = foodService.getFoodsFromMeal(meal: K.Api.food.breakfast)
            cell.backgroundColor = UIColor.clear
            cell.label.text = food[indexPath.row].name + " " + String(Int(food[indexPath.row].calories))
            cell.deleteAction = { [] in
                self.foodService.removeFoodItemFromMeal(meal: K.Api.food.breakfast, foodItem: food[indexPath.row])
            }
            return cell
        }
        else if tableView ==  tableViewLunch {
            let cell = tableViewLunch.dequeueReusableCell(withIdentifier: K.foodCell.cellIdentifier , for: indexPath) as! FoodCell
            let food = foodService.getFoodsFromMeal(meal: K.Api.food.lunch)
            cell.backgroundColor = UIColor.clear
            cell.label.text = food[indexPath.row].name + " " + String(Int(food[indexPath.row].calories))
            cell.deleteAction = { [] in
                self.foodService.removeFoodItemFromMeal(meal: K.Api.food.lunch, foodItem: food[indexPath.row])
            }
            return cell
        }
        else {
            let cell = tableViewDinner.dequeueReusableCell(withIdentifier: K.foodCell.cellIdentifier , for: indexPath) as! FoodCell
            let food = foodService.getFoodsFromMeal(meal: K.Api.food.dinner)
            cell.backgroundColor = UIColor.clear
            cell.label.text = food[indexPath.row].name + " " + String(Int(food[indexPath.row].calories))
            cell.deleteAction = { [] in
                self.foodService.removeFoodItemFromMeal(meal: K.Api.food.dinner, foodItem: food[indexPath.row])
            }
            return cell
        }
    }
}

//deselecting other tables when in a table
extension MealsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableViews = [tableViewBreak, tableViewLunch, tableViewDinner]
        
        for table in tableViews {
            if table != tableView {
                table?.indexPathsForSelectedRows?.forEach{ indexPath in
                    table?.deselectRow(at: indexPath, animated: true)
                }
            }
        }
    }
}

extension MealsViewController : MealsViewControllerDelegate {
    func didAddFoodItem() {
        tableViewBreak.reloadData()
        tableViewLunch.reloadData()
        tableViewDinner.reloadData()
    }
}

