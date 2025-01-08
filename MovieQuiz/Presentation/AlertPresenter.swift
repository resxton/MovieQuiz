//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 05.12.2024.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    // MARK: - Properties
    private weak var delegate: AlertPresenterDelegate?
    
    // MARK: - Methods
    func showAlert(from model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Alert"
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        self.delegate?.didReceiveAlert(alert: alert)
    }
    
    init(delegate: AlertPresenterDelegate? = nil) {
        self.delegate = delegate
    }
}
