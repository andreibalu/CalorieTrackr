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
        let parameters: [String: Any] = ["query": query]
        
        AF.request(K.Api.url, method: .get, parameters: parameters, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let JSON = value as? [String: Any],
                       let common = JSON["common"] as? [[String: Any]],
                       let branded = JSON["branded"] as? [[String: Any]] {
                        var items = [FoodItem]()
                        common.forEach { item in
                            if let name = item["food_name"] as? String {
                                items.append(FoodItem(name: name, type: "common"))
                            }
                        }
                        branded.forEach { item in
                            if let name = item["food_name"] as? String {
                                items.append(FoodItem(name: name, type: "branded"))
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
