//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 05.12.2024.
//

import UIKit

class ResultAlertPresenter: ResultAlertPresenterProtocol {
    // MARK: - Properties
    private weak var delegate : ResultAlertPresenterDelegate?
    
    // MARK: - Methods
    func showAlert(from model: ResultAlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        self.delegate?.didReceiveAlert(alert: alert)
    }
    
    func setDelegate(_ delegate: ResultAlertPresenterDelegate) {
        self.delegate = delegate
    }
}
