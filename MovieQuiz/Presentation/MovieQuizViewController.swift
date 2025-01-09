import UIKit


final class MovieQuizViewController: UIViewController,
                                     MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private properties
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let notificationLikeImpact = UINotificationFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private var alertPresenter: AlertPresenterProtocol?
    
    private var presenter: MovieQuizPresenter!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
                
        alertPresenter = AlertPresenter()
        
        changeAppearanceOfLoadingIndicator(to: true)
    }
    
    // MARK: - Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Public Methods
    func show(quiz step: QuizStepViewModel) {
        hideResult()
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
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.masksToBounds = true
        
        if isCorrectAnswer == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswerFeedback()
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            wrongAnswerFeedback()
        }
        
        setButtonsEnabled(false)
    }
    
    func changeAppearanceOfLoadingIndicator(to status: Bool) {
        status ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        changeAppearanceOfLoadingIndicator(to: false)
        
        let alertModel = AlertModel(title: "Что-то пошло не так(",
                                    message: "Невозможно загрузить данные",
                                    buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            self.presenter.reloadGame()
        }
        
        alertPresenter?.showAlert(in: self, from: alertModel)
    }
    
    // MARK: - Private methods
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func showNextQuestionOrResult() {
        presenter.showNextQuestionOrResult()
    }
    
    private func correctAnswerFeedback() {
        notificationLikeImpact.notificationOccurred(.success)
        
        lightImpact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.lightImpact.impactOccurred(intensity: 0.7)
        }
    }
    
    private func wrongAnswerFeedback() {
        mediumImpact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.mediumImpact.impactOccurred(intensity: 0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            self.mediumImpact.impactOccurred(intensity: 1.0)
        }
    }
    
    private func hideResult() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
}
