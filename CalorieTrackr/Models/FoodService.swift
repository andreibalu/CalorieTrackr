//
//  NutritionixAPIManager.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 18.05.2023.
//

import Alamofire

class FoodService {
    
    private let headers: HTTPHeaders = [
        "Content-Type": "application/json",
        "x-app-id": K.Api.appid,
        "x-app-key": K.Api.appkey
    ]
    
    func searchFoodItems(query: String, completion: @escaping (Result<[FoodItem], Error>) -> Void) {
        let parameters: [String: Any] = ["query": query,"use_branded_foods": true]
        
        AF.request("https://trackapi.nutritionix.com/v2/natural/nutrients", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let JSON = value as? [String: Any],
                       let foods = JSON["foods"] as? [[String: Any]] {
                        var items = [FoodItem]()
                        foods.forEach { item in
                            if let name = item["food_name"] as? String,
                                let grams = item["serving_weight_grams"] as? Double,
                                let proteins = item["nf_protein"] as? Double,
                                let calories = item["nf_calories"] as? Double {
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
}
