//
//  NutritionixAPIManager.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 18.05.2023.
//

import Alamofire
import CoreData

class FoodService {
    
    private let mealsFileURL: URL = {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(K.foodJson)
    }()
    
    private let headers: HTTPHeaders = [
        "Content-Type": "application/json",
        "x-app-id": K.Api.appid,
        "x-app-key": K.Api.appkey
    ]
    
    func searchFoodItems(query: String, completion: @escaping (Result<[FoodItem], Error>) -> Void) {
        let parameters: [String: Any] = ["query": query,"use_branded_foods": true]
        
        AF.request(K.Api.url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let JSON = value as? [String: Any],
                       let foods = JSON[K.Api.array] as? [[String: Any]] {
                        var items = [FoodItem]()
                        foods.forEach { item in
                            if let name = item[K.Api.food.name] as? String,
                               let grams = item[K.Api.food.grams] as? Double,
                               let proteins = item[K.Api.food.proteins] as? Double,
                               let calories = item[K.Api.food.calories] as? Double {
                                items.append(FoodItem(name: name, calories: calories, proteins: proteins, grams: grams))
                            }
                        }
                        completion(.success(items))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    //add a food to a specific meal
    func addToMeal(meal: String, foodItem: FoodItem) {
        print("Adding \(foodItem.name) to \(meal)")
        
        var meals = getMealsFromFile()
        meals[meal, default: []].append(foodItem)
        
        saveMealsToFile(meals: meals)
    }
    
    //delete a specific food from a specific meal
    func removeFoodItemFromMeal(meal: String, foodItem: FoodItem) {
        var meals = getMealsFromFile()
        
        meals[meal] = meals[meal]?.filter { $0 != foodItem }
        saveMealsToFile(meals: meals)
        print("Removed \(foodItem.name) from file.")
    }
    
    //to print the foods of a meal -> ex: breakfast meals
    func printOneMeal(from meal: String) {
        let meals = getMealsFromFile()
        
        guard let foods = meals[meal] else {
            print("No foods found for \(meal).")
            return
        }
        
        for food in foods {
            print("Name: \(food.name), Calories: \(food.calories), Proteins: \(food.proteins), Grams: \(food.grams)")
        }
    }
    
    //return the whole file content
    func getMealsFromFile() -> [String: [FoodItem]] {
        guard let data = try? Data(contentsOf: mealsFileURL),
              let meals = try? JSONDecoder().decode([String: [FoodItem]].self, from: data) else {
            print("No meals found or couldn't decode the file.")
            return [:]
        }
        return meals
    }
    
    //empty the file
    func emptyMealsFile() {
        let emptyMeals: [String: [FoodItem]] = [:]
        saveMealsToFile(meals: emptyMeals)
        print("Emptied meals file.")
    }
    
    //saves new content to meals file
    func saveMealsToFile(meals: [String: [FoodItem]]) {
        guard let data = try? JSONEncoder().encode(meals) else { return }
        try? data.write(to: mealsFileURL)
        print("Saved new content.")
    }
}