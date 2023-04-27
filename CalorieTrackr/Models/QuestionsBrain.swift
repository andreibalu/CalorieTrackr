//
//  QuestionsBrain.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 26.04.2023.
//

import Foundation

struct QuestionsBrain{
    let questions = [   Questions(q: "What's your name"),
                        Questions(q: "What is your sex?"),
                        Questions(q: "How old are you"),
                        Questions(q: "How tall are you"),
                        Questions(q: "What's your weight"),
                        Questions(q: "What is your ideal weight"),
                        Questions(q: "In how many weeks do you want to reach your ideal weight"),
                        Questions(q: "How many times do you exercise every week?")
    ]
    
    let sex = ["","Male", "Female", "Other", "Dino"]
    var age : [String] {
        let s = 1...99
        return s.map { String($0) }
    }
    var height : [String] {
        let s = 130...210
        return s.map { String($0) }
    }
    var weight : [String] {
        let s = 30...160
        return s.map { String($0) }
    }
    var ideal : [String] {
        let s = 30...160
        return s.map { String($0) }
    }
    var weeks : [String] {
        let s = 5...50
        return s.map { String($0) }
    }
    var ex : [String] {
        let s = 1...7
        return s.map { String($0) }
    }
    
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
}
