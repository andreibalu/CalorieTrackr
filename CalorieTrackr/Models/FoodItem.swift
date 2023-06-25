//
//  FoodItem.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 18.05.2023.
//

import Foundation

struct FoodItem: Codable, Equatable {
    let id: UUID
    let name: String
    let calories: Double
    let proteins: Double
    let carbs: Double
    let fats: Double
    let grams: Double
    
    static func ==(lhs: FoodItem, rhs: FoodItem) -> Bool {
        return lhs.name == rhs.name &&
               lhs.calories == rhs.calories &&
               lhs.proteins == rhs.proteins &&
               lhs.carbs == rhs.carbs &&
               lhs.fats == rhs.fats &&
               lhs.grams == rhs.grams
    }
}

