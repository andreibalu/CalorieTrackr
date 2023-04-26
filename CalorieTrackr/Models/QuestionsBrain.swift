//
//  QuestionsBrain.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 26.04.2023.
//

import Foundation

struct QuestionsBrain{
    let questions = [   Questions(q: "What's your name", needs: "textField"),
                        Questions(q: "What is your sex?", needs: "pickerViewSex"),
                        Questions(q: "How old are you", needs: "pickerView"),
                        Questions(q: "How tall are you", needs: "pickerView"),
                        Questions(q: "What's your weight", needs: "pickerView"),
                        Questions(q: "What is your ideal weight", needs: "pickerView"),
                        Questions(q: "In how many weeks do you want to reach your ideal weight", needs: "pickerView"),
                        Questions(q: "How many times do you exercise every week?", needs: "pickerView")
    ]
    
    let sex = ["Male", "Female", "Other", "Dino"]
    
    var QuestionNumber = 0
    var QuestionsCount : Int {
        return questions.count
    }
    
    func getQuestionNumber() -> Int {
        return QuestionNumber
    }
    
    mutating func nextQuestion(){
        if QuestionNumber < QuestionsCount {
            QuestionNumber = QuestionNumber + 1
        }
    }
    
    mutating func prevQuestion(){
        QuestionNumber = QuestionNumber - 1
    }
    
    func getQuestionQ() -> String {
        return questions[QuestionNumber].q
    }
    
    func getQuestionNeeds() -> String {
        return questions[QuestionNumber].needs
    }
    
}
