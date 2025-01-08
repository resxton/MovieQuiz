import UIKit


final class MovieQuizViewController: UIViewController,
                                     QuestionFactoryDelegate,
                                     AlertPresenterDelegate {
    // MARK: - Private properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let impact = UIImpactFeedbackGenerator(style: .medium)
    private let generator = UINotificationFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        
        alertPresenter = AlertPresenter(delegate: self)
        
        changeAppearingOfLoadingIndicator(to: true)
        
        questionFactory?.loadData()
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        .init(
            image: UIImage(data: model.image) ?? UIImage(),
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
    
    private func show(quiz result: QuizResultsViewModel) {
        alertPresenter?.showAlert(from: AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: { [weak self] in
            guard let self else { return }
            currentQuestionIndex = 0
            correctAnswers = 0
            
            questionFactory?.requestNextQuestion()
        }))
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in 
            guard let self else { return }
            self.hideResult()
            self.changeAppearingOfLoadingIndicator(to: true)
            self.showNextQuestion()
        }
    }
    
    private func hideResult() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func showNextQuestion() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount, date: Date())
            
            let text = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            
            let quizResults = QuizResultsViewModel(title: "Этот раунд окончен!", text: text, buttonText: "Сыграть еще раз")
            
            show(quiz: quizResults)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func correctAnswerFeedback() {
        generator.notificationOccurred(.success)
        
        lightImpact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.lightImpact.impactOccurred(intensity: 0.7)
        }
    }
    
    private func wrongAnswerFeedback() {
        impact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.impact.impactOccurred(intensity: 0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            self.impact.impactOccurred(intensity: 1.0)
        }
    }
    
    private func changeAppearingOfLoadingIndicator(to status: Bool) {
        status ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        changeAppearingOfLoadingIndicator(to: false)
        
        let alertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }

            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showAlert(from: alertModel)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        changeAppearingOfLoadingIndicator(to: false)
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        changeAppearingOfLoadingIndicator(to: false)
        
        showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadData(with message: String) {
        changeAppearingOfLoadingIndicator(to: false)
        
        showNetworkError(message: message)
    }
    
    func didFailToLoadImage() {
        changeAppearingOfLoadingIndicator(to: false)
        
        let loadFailAlertModel = AlertModel(title: "Ошибка", message: "Возникла проблема с загрузкой картинки", buttonText: "Начать заново") { [weak self] in
                guard let self else { return }
                currentQuestionIndex = 0
                correctAnswers = 0
                
                questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showAlert(from: loadFailAlertModel)
    }
    
    // MARK: - AlertPresenterDelegate
    func didReceiveAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    // MARK: - Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
