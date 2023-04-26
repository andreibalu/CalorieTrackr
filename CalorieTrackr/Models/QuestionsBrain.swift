//
//  QuestionsBrain.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 26.04.2023.
//

import Foundation

struct QuestionsBrain{
    let questions = [   Questions(q: "What's your name", needs: "TextField"),
                        Questions(q: "How old are you", needs: "PickerView"),
                        Questions(q: "How tall are you", needs: "PickerView"),
                        Questions(q: "What's your weight", needs: "PickerView"),
                        Questions(q: "What is your ideal weight", needs: "PickerView"),
                        Questions(q: "In how many weeks do you want to reach your ideal weight", needs: "PickerView"),
                        Questions(q: "How many times do you exercise every week?", needs: "PickerView")
    ]
    
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
