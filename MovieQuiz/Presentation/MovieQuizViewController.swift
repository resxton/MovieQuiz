import UIKit


final class MovieQuizViewController: UIViewController {
    // MARK: - Public properties
    var alertPresenter: AlertPresenterProtocol?
    
    // MARK: - Private properties
    private let impact = UIImpactFeedbackGenerator(style: .medium)
    private let generator = UINotificationFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private var presenter: MovieQuizPresenter!
    
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
        
        presenter = MovieQuizPresenter(viewController: self)
                
        alertPresenter = AlertPresenter()
        
        changeAppearanceOfLoadingIndicator(to: true)
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Public Methods
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.borderWidth = 8
        imageView.layer.masksToBounds = true
        
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswerFeedback()
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            wrongAnswerFeedback()
        }
        
        setButtonsEnabled(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.hideResult()
            self.changeAppearanceOfLoadingIndicator(to: true)
            self.showNextQuestionOrResult()
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        setButtonsEnabled(true)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        alertPresenter?.showAlert(in: self, from: AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
        }))
    }
    
    func changeAppearanceOfLoadingIndicator(to status: Bool) {
        status ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        changeAppearanceOfLoadingIndicator(to: false)
        
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            self.presenter.reloadGame()
        }
        
        alertPresenter?.showAlert(in: self, from: alertModel)
    }
    
    // MARK: - Private methods
    private func hideResult() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func showNextQuestionOrResult() {
        presenter.showNextQuestionOrResult()
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
    
    // MARK: - Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
