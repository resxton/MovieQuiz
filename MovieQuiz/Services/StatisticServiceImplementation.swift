//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 12.12.2024.
//

import Foundation

final class StatisticServiceImplementation: StatisticService {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct
        case totalCorrect
        case bestGame
        case gamesCount
        case total
        case totalQuestions
        case date
    }
    
    var correct: Int {
        get {
            storage.integer(forKey: Keys.correct.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var totalCorrect: Int {
        get {
            storage.integer(forKey: Keys.totalCorrect.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrect.rawValue)
        }
    }
    
    var totalQuestions: Int {
        get {
            storage.integer(forKey: Keys.totalQuestions.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestions.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue)
            return GameResult(correct: correct, total: total, date: date as? Date ?? Date())
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        guard totalQuestions > 0 else { return 0.0 }
        return (Double(totalCorrect) / Double(totalQuestions)) * 100.0
    }

    func store(correct count: Int, total amount: Int, date: Date) {
        let currentResult = GameResult(correct: count, total: amount, date: date)
        bestGame = bestGame.compareResult(with: currentResult)
        totalCorrect += count
        totalQuestions += amount
        gamesCount += 1
    }
}
