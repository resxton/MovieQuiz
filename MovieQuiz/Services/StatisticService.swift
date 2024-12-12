//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 12.12.2024.
//

import UIKit

protocol StatisticService {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    var correct: Int { get }
    var totalCorrect: Int { get }
    var totalQuestions: Int { get }
    
    func store(correct count: Int, total amount: Int, date: Date)
}
