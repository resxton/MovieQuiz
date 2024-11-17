import UIKit


final class MovieQuizViewController: UIViewController {
    // MARK: - Private properties
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentQuestion = questions[currentQuestionIndex]
        show(quiz: convert(model: currentQuestion))
    }
    
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let isCorrect = (questions[currentQuestionIndex].correctAnswer == false)
        showAnswerResult(isCorrect: isCorrect)
    }
    
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let isCorrect = (questions[currentQuestionIndex].correctAnswer == true)
        showAnswerResult(isCorrect: isCorrect)
    }
    
    
    // MARK: - Private methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex+1)/\(questions.count)")
    }
    
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        enableButtons()
    }
    
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.masksToBounds = true
        
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswerFeedback()
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            wrongAnswerFeedback()
        }
        
        disableButtons()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hideResult()
            self.showNextQuestionOrResults()
        }
    }
    
    
    private func hideResult() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    
    private func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    
    private func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!", text: "Ваш результат \(correctAnswers)/\(questions.count)", buttonText: "Начать заново"))
        } else {
            currentQuestionIndex += 1
            
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
    }
    

    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func correctAnswerFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impact.impactOccurred(intensity: 0.7)
        }
    }
    
    
    private func wrongAnswerFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impact.impactOccurred(intensity: 0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            impact.impactOccurred(intensity: 1.0)
        }
    }
}


// MARK: - Models
private struct QuizQuestion {
  let image: String
  let text: String
  let correctAnswer: Bool
}


private struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}


private struct QuizResultsViewModel {
  let title: String
  let text: String
  let buttonText: String
}
