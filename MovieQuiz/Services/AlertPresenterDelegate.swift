//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 05.12.2024.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didReceiveAlert(alert: UIAlertController)
}
