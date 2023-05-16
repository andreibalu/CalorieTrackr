//
//  BMI.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 15.05.2023.
//

import Foundation

struct BmiBrain {
    
    var sex : String
    var age : String
    var height: String
    var weight : String
    var ideal : String
    var weeks : String
    var ex : String
    
    
    init(sex: String, age: String, height: String, weight: String, ideal: String, weeks: String, ex: String) {
        self.sex = sex
        self.age = age
        self.height = height
        self.weight = weight
        self.ideal = ideal
        self.weeks = weeks
        self.ex = ex
    }
    
    var ageD : Double {
        return Double(age)!
    }
    var heightD : Double {
        return Double(height)!
    }
    var weightD : Double {
        return Double(weight)!
    }
    var idealD : Double {
        return Double(ideal)!
    }
    var weeksD : Double {
        return Double(weeks)!
    }
    var exD : Double {
        return Double(ex)!
    }
    var sexD : Double {//because the formula makes men need 5 more calories and women need 161 less, we added 5 implicitly and we either substract none or substract 166
        if sex == K.Sex.female{
            return -166.0
        }
        else {
            return 0.0
        }
    }
    
    var BMR : String{
        switch exD {
        case 0 :
            return String(Int((10 * weightD + 6.25 * heightD - 5 * ageD + 5 + sexD) * 1.2))
        case 1, 2:
            return String(Int((10 * weightD + 6.25 * heightD - 5 * ageD + 5 + sexD) * 1.375))
        case 3:
            return String(Int((10 * weightD + 6.25 * heightD - 5 * ageD + 5 + sexD) * 1.55))
        case 4, 5:
            return String(Int((10 * weightD + 6.25 * heightD - 5 * ageD + 5 + sexD) * 1.725))
        case 6, 7:
            return String(Int((10 * weightD + 6.25 * heightD - 5 * ageD + 5 + sexD) * 1.9))
        default:
            return "error at calculating bmr based on exercises per week"
        }
    }
    func getTarget() -> String {
        var diffD = idealD - weightD
        if diffD > 0 { // gain weight
            let kgPerWeek = diffD / weeksD  //weight gain per week
            //considering 1kg_gain/week -> 500cals/day
            let calsPerDay = kgPerWeek * 500
            return String(format: "%.0f",Double(BMR)! + calsPerDay)
        }
        else {
            diffD.negate()
            let kgPerWeek = diffD / weeksD
            //considering 1kg_loss/week -> 1000cals/day
            let calsPerDay = kgPerWeek * 1000
            return String(format: "%.0f",Double(BMR)! - calsPerDay)
        }
    }
}
