//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 12.12.2024.
//

import Foundation

struct GameResult {
    // MARK: - Public Properties
    let correct: Int
    let total: Int
    let date: Date
    
    // MARK: - Public Methods
    func compareResult(with anotherResult: GameResult) -> GameResult {
        correct > anotherResult.correct ? self : anotherResult
    }
}
