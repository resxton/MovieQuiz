//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 27.11.2024.
//

import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}