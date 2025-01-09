//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 09.01.2025.
//

import UIKit

final class MovieQuizPresenter {
    // MARK: - Public Properties
    let questionsAmount: Int = 10
    
    // MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    
    // MARK: - Public Methods
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        .init(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
