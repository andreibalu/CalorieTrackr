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
        static let senderField = "sender"
        static let nameField = "name"
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
    
    static let appName = "CalorieTrackr"
    static let registerSegue = "RegisterToSurvey"
    static let loginSegue = "LoginToApp"
}
