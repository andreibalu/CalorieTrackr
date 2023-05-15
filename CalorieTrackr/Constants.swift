//
//  Constants.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 22.04.2023.
//

struct K {
    struct AppColors {
        static let purple = "ColorPurple"
        static let pink = "ColorPink"
        static let navy = "ColorNavy"				
        static let crem = "ColorCrem"
    }
    
    struct FStore {
        static let collectionName = "Users"
        static let senderField = "Email"
        static let name = "Name"
        static let sex = "Sex"
        static let age = "Age"
        static let height = "Height"
        static let weight = "Weight"
        static let ideal = "IdealWeight"
        static let weeks = "WeeksGoal"
        static let ex = "Activity"
        static let streak = "Streak"
        static let target = "Target"
        static let dateField = "date"
    }
    
    struct Survey {
        static let nameField = "textField"
        static let pickerSex = "pickerViewSex"
        static let pickerAge = "pickerViewAge"
        static let pickerHeight = "pickerViewHeight"
        static let pickerWeight = "pickerViewWeight"
        static let pickerIdeal = "pickerViewIdeal"
        static let pickerWeeks = "pickerViewWeeks"
        static let pickerEx = "pickerViewEx"
    }
    
    struct Images{
        static let muscle = "muscleImage"
    }
    
    struct Sex{
        static let male = "Male"
        static let female = "Female"
        static let other = "Other"
    }
    
    struct ActivityLevel{
        static let sedentary = "1.2"
        static let light = "1.375"
        static let moderate = "1.55"
        static let high = "1.725"
        static let very = "1.9"
    }
    
    static let appName = "CalorieTrackr"
    static let registerSegue = "RegisterToSurvey"
    static let loginSegue = "LoginToApp"
    static let logout = "returnToWelcome"
}
