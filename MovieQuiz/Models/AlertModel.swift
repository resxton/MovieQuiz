//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Сомов Кирилл on 05.12.2024.
//

import UIKit

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
