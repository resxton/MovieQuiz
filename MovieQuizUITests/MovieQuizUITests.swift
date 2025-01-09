//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Сомов Кирилл on 08.01.2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() throws {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]

        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoButton() throws {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]

        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testResultAlert() throws {
        let button = app.buttons["Yes"]
        sleep(1)
        
        for _ in 0..<10 {
            button.tap()
            sleep(1)
        }
        
        let resultAlert = app.alerts["Alert"]
        XCTAssertTrue(resultAlert.exists, "Алерт не существует")
        let alertButton = resultAlert.buttons.firstMatch
        XCTAssertEqual(alertButton.label, "Сыграть еще раз", "Неверный текст кнопки")
    }
    
    func testResultAlertDismiss() throws {
        let button = app.buttons["Yes"]
        sleep(1)
        
        for _ in 0..<10 {
            button.tap()
            sleep(1)
        }
        
        let resultAlert = app.alerts["Alert"]
        XCTAssertTrue(resultAlert.exists, "Алерт не существует")
        let alertButton = resultAlert.buttons.firstMatch
        XCTAssertEqual(alertButton.label, "Сыграть еще раз", "Неверный текст кнопки")
        alertButton.tap()
        
        sleep(1)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
