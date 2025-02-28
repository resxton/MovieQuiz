//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 05.12.2024.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    // MARK: - Public Methods
    func showAlert(in vc: UIViewController, from model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Alert"
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        
        vc.present(alert, animated: true)
    }
}
