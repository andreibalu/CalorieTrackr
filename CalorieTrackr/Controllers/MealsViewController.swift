//
//  MealsViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 18.05.2023.
//

import Foundation
import UIKit
import Alamofire

class MealsViewController: UIViewController {
    
    let baseUrl = "https://api.nutritionix.com/v1_1/"
    let appId = "f78c03db"
    let appKey = "768fa88c0628a45dce2a28a11565dd9c"
    let query = "apple"
    let results = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchFoodItems()
    }
    
    func searchFoodItems() {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-app-id": "f78c03db",
            "x-app-key": "768fa88c0628a45dce2a28a11565dd9c"
        ]

        let parameters: [String: Any] = [
            "query": "apple"
        ]

        AF.request("https://trackapi.nutritionix.com/v2/search/instant", method: .get, parameters: parameters, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print(value)
                case .failure(let error):
                    print(error)
                }
            }
    }

}
