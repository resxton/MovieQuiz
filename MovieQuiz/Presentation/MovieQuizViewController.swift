import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Private properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let impact = UIImpactFeedbackGenerator(style: .medium)
    private let generator = UINotificationFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.setDelegate(self)
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
 
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        .init(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        setButtonsEnabled(true)
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
        
        setButtonsEnabled(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { #warning("Set back to 1.0")
            self.hideResult()
            self.showNextQuestionOrResults()
        }
    }
    
    private func hideResult() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
                    "Поздравляем, вы ответили на 10 из 10!" :
                    "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            show(quiz: QuizResultsViewModel(title: "Раунд окончен!", text: text, buttonText: "Сыграть еще раз"))
        } else {
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            questionFactory?.requestNextQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func correctAnswerFeedback() {
        generator.notificationOccurred(.success)
        
        lightImpact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.lightImpact.impactOccurred(intensity: 0.7)
        }
    }
    
    private func wrongAnswerFeedback() {
        impact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.impact.impactOccurred(intensity: 0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.impact.impactOccurred(intensity: 1.0)
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
