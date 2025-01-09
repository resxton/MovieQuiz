//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 09.01.2025.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func changeAppearanceOfLoadingIndicator(to status: Bool)
    
    func showNetworkError(message: String)
}

