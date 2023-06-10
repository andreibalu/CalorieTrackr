//
//  WatchData.swift
//  CalorieTrackr
//
//  Created by Andrei Tatucu on 10.06.2023.
//

import Foundation

struct WatchData: Codable, Equatable {
    let id: UUID
    let consumedCalories: Double
    let burnedCalories: Double
    let proteins: Double
    let carbs: Double
    let fats: Double
}
