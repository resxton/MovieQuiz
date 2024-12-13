//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 05.12.2024.
//

import UIKit

protocol ResultAlertPresenterDelegate: AnyObject {
    func didReceiveAlert(alert: UIAlertController)
}
