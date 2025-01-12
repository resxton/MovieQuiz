//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 12.12.2024.
//

import UIKit

protocol StatisticService {
    
    // MARK: - Public Properties
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    var correct: Int { get }
    var totalCorrect: Int { get }
    var totalQuestions: Int { get }
    
    // MARK: - Public Methods
    func store(correct count: Int, total amount: Int, date: Date)
}
