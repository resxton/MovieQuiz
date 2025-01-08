//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 22.11.2024.
//

import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    // MARK: - Private properties
    private var movies: [MostPopularMovie] = []
    private weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    
    // MARK: - init
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    // MARK: - Methods
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.delegate?.didFailToLoadImage()
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let (text, correctAnswer) = generateQuestion(from: rating, randomized: false)
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    /// Генерирует вопрос для квиза на основе рейтинга фильма.
    ///
    /// Эта функция формирует вопрос, сравнивающий рейтинг фильма с определенным пороговым значением.
    /// Пороговое значение либо выбирается случайным образом, либо округляется от исходного значения рейтинга.
    /// Вопрос будет на тему "больше чем" или "меньше чем", в зависимости от случайного выбора.
    ///
    /// - Parameters:
    ///   - score: Рейтинг фильма, на основе которого генерируется вопрос.
    ///   - randomized: Если `true`, пороговое значение будет выбрано случайным образом. Если `false`, порог будет округлен от значения `score`.
    /// - Returns: Кортеж, содержащий текст вопроса и булево значение, которое указывает, верно ли утверждение о сравнении рейтинга с порогом.
    ///
    /// Пример:
    /// ```swift
    /// let score: Float = 7.3
    /// let (question, correctAnswer) = generateQuestion(from: score, randomized: true)
    /// print(question)        // Пример: "Рейтинг этого фильма больше чем 3?"
    /// print(correctAnswer)   // true или false, в зависимости от того, больше ли score порога
    /// ```
    func generateQuestion(from score: Float, randomized: Bool) -> (String, Bool) {
        var text = "Рейтинг этого фильма "
        var targetAmount = 0
        if randomized {
            targetAmount = Int.random(in: 1..<10)
        } else {
            targetAmount = Int(score.rounded())
        }
        
        if Bool.random() {
            text += "больше чем \(targetAmount)?"
            return (text, score > Float(targetAmount))
        } else {
            text += "меньше чем \(targetAmount)?"
            return (text, score < Float(targetAmount))
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let MostPopularMovies):
                    guard MostPopularMovies.items.count > 0 else {
                        self.delegate?.didFailToLoadData(with: MostPopularMovies.errorMessage)
                        return
                    }
                    self.movies = MostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
