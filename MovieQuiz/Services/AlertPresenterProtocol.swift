//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 05.12.2024.
//

import UIKit

protocol AlertPresenterProtocol {
    func showAlert(in vc: UIViewController, from model: AlertModel)
}
