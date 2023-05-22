//
//  MealsViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 18.05.2023.
//

import UIKit
import SwipeCellKit

class MealsViewController: UIViewController {
    private var foodService: FoodService!

    @IBOutlet weak var tableViewDinner: UITableView!
    @IBOutlet weak var tableViewLunch: UITableView!
    @IBOutlet weak var tableViewBreak: UITableView!
    @IBOutlet weak var totalCalories: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodService = FoodService()
        
        setUpTables()
        totalCalories.text = String(Int(self.foodService.getTotalCaloriesFromMealFile()))
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTables), name: NSNotification.Name(rawValue: K.Api.food.notif), object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTables()
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
    
    private func setUpTables() {
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
    @objc private func reloadTables() {
        tableViewBreak.reloadData()
        tableViewLunch.reloadData()
        tableViewDinner.reloadData()
        totalCalories.text = "Total Calories: " + String(Int(self.foodService.getTotalCaloriesFromMealFile()))
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
            cell.delegate = self
            return cell
        }
        else if tableView ==  tableViewLunch {
            let cell = tableViewLunch.dequeueReusableCell(withIdentifier: K.foodCell.cellIdentifier , for: indexPath) as! FoodCell
            let food = foodService.getFoodsFromMeal(meal: K.Api.food.lunch)
            cell.backgroundColor = UIColor.clear
            cell.label.text = food[indexPath.row].name + " " + String(Int(food[indexPath.row].calories))
            cell.delegate = self
            return cell
        }
        else {
            let cell = tableViewDinner.dequeueReusableCell(withIdentifier: K.foodCell.cellIdentifier , for: indexPath) as! FoodCell
            let food = foodService.getFoodsFromMeal(meal: K.Api.food.dinner)
            cell.backgroundColor = UIColor.clear
            cell.label.text = food[indexPath.row].name + " " + String(Int(food[indexPath.row].calories))
            cell.delegate = self
            return cell
        }
    }
}

extension MealsViewController : SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
            guard let self = self else { return }
            if tableView == self.tableViewBreak {
                self.deleteFoodItem(from: K.Api.food.breakfast, at: indexPath.row)
            } else if tableView == self.tableViewLunch {
                self.deleteFoodItem(from: K.Api.food.lunch, at: indexPath.row)
            } else if tableView == self.tableViewDinner {
                self.deleteFoodItem(from: K.Api.food.dinner, at: indexPath.row)
            }
        }
        deleteAction.image = UIImage(named: "delete")
        return [deleteAction]
    }

    private func deleteFoodItem(from meal: String, at index: Int) {
        let food = self.foodService.getFoodsFromMeal(meal: meal)
        self.foodService.removeFoodItemFromMeal(meal: meal, foodItem: food[index])
        self.reloadTables()
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


