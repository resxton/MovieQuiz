//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 09.01.2025.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {    
    // MARK: - Public Properties
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    var correctAnswers = 0
    var statisticService: StatisticService = StatisticServiceImplementation()
    
    // MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    
    // MARK: - Initializers
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        viewController.changeAppearanceOfLoadingIndicator(to: true)
    }
    
    // MARK: - Public Methods
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
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
    
    func restartGame() {
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()
    }
    
    func reloadGame() {
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.loadData()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func showNextQuestionOrResult() {
        if self.isLastQuestion() {
            guard let viewController else { return }
            statisticService.store(correct: self.correctAnswers, total: self.questionsAmount, date: Date())
            
            let text = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            
            let quizResults = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                   text: text,
                                                   buttonText: "Сыграть еще раз")
            
            viewController.show(quiz: quizResults)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer == true {
            correctAnswers += 1
        }
    }
    
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        viewController?.changeAppearanceOfLoadingIndicator(to: false)
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.changeAppearanceOfLoadingIndicator(to: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.changeAppearanceOfLoadingIndicator(to: false)
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadData(with message: String) {
        viewController?.changeAppearanceOfLoadingIndicator(to: false)
        viewController?.showNetworkError(message: message)
    }
    
    func didFailToLoadImage() {
        viewController?.changeAppearanceOfLoadingIndicator(to: false)
        
        let loadFailAlertModel = AlertModel(title: "Ошибка",
                                            message: "Возникла проблема с загрузкой картинки",
                                            buttonText: "Начать заново") { [weak self] in
            guard let self else { return }
            reloadGame()
            questionFactory?.requestNextQuestion()
        }
        
        viewController?.alertPresenter?.showAlert(in: viewController ?? MovieQuizViewController(), from: loadFailAlertModel)
    }
}
