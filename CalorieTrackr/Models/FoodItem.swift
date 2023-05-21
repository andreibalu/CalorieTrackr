//
//  FoodItem.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 18.05.2023.
//

import Foundation

struct FoodItem: Codable, Equatable {
    let name: String
    let calories: Double
    let proteins: Double
    let grams: Double
    
    static func ==(lhs: FoodItem, rhs: FoodItem) -> Bool {
        return lhs.name == rhs.name &&
               lhs.calories == rhs.calories &&
               lhs.proteins == rhs.proteins &&
               lhs.grams == rhs.grams
    }
}
