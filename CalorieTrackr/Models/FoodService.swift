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
                                items.append(FoodItem(id: UUID(), name: name, calories: calories, proteins: proteins, grams: grams))
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
        print("Adding \(foodItem.name) to \(meal) with \(foodItem.calories) calories, \(foodItem.grams)grams and \(foodItem.proteins) proteins")
        
        var meals = getMealsFromFile()
        meals[meal, default: []].append(foodItem)
                
        saveMealsToFile(meals: meals)
    }
    
    //delete a specific food from a specific meal
    func removeFoodItemFromMeal(meal: String, foodItem: FoodItem) {
        var meals = getMealsFromFile()

        meals[meal] = meals[meal]?.filter { $0.id != foodItem.id }
        saveMealsToFile(meals: meals)
        print("Removed \(foodItem.name) from file.")
    }
    
    //count all foods from a meal
    func getFoodsCountFromMeal(meal: String) -> Int {
        let meals = getMealsFromFile()
        guard let foods = meals[meal] else {
            print("No foods found for \(meal).")
            return 0
        }
        return foods.count
    }
    
    //optional func -- to print the foods of a meal -> ex: breakfast meals
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
    
    //get all foods from a meal
    func getFoodsFromMeal(meal: String) -> [FoodItem] {
        let meals = getMealsFromFile()
        
        guard let foods = meals[meal] else {
            print("No foods found for \(meal).")
            return []
        }
        
        return foods
    }

    //get sum of calories
    func getTotalCaloriesFromMealFile() -> Double {
        let meals = getMealsFromFile()
        
        var totalCalories: Double = 0.0
        
        for (_, foods) in meals {
            for food in foods {
                totalCalories += food.calories
            }
        }
        
        return totalCalories
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
    
    //optional func -- empty the file
    func emptyMealsFile() {
        let emptyMeals: [String: [FoodItem]] = [:]
        saveMealsToFile(meals: emptyMeals)
        print("Emptied meals file.")
    }
    
    //writes new content to meals file
    func saveMealsToFile(meals: [String: [FoodItem]]) {
        guard let data = try? JSONEncoder().encode(meals) else { return }
            do {
                try data.write(to: mealsFileURL)
                print("Saved new content.")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: K.Api.food.notif), object: nil)
            } catch {
                print("Failed to save new content: \(error)")
            }
    }
    
    //if a new day started, empty the json
    func refreshForToday() {
        if let storedDate = UserDefaults.standard.object(forKey: "lastAccessedDate") as? Date {
            print("Last accessed this app on: \(storedDate). Will check if new day.")
            if !Calendar.current.isDateInToday(storedDate) {
                print("Will empty meals.")
                emptyMealsFile()
            } else {
                print("It is not a new day.")
            }
        } else {
            print("Can't get last accessed date for app.")
        }
        // Update the last accessed date to now
    }

}
