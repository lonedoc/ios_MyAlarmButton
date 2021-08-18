//
//  MainViewController.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 27/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit
import Swinject
import AudioToolbox

class MainViewController: UIViewController {

    private let presenter: MainContract.Presenter
    private var rootView: MainView { return self.view as! MainView } // swiftlint:disable:this force_cast

    init(with presenter: MainContract.Presenter) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = MainView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        presenter.attach(view: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter.viewWillAppear()
        configureControls()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.viewWillDisappear()
    }

    private func configureControls() {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didHitAlarmButton(sender:)))
        recognizer.minimumPressDuration = 1.5
        rootView.alarmButton.addGestureRecognizer(recognizer)
        rootView.testButton.addTarget(self, action: #selector(didHitTestButton), for: .touchUpInside)
        rootView.patrolButton.addTarget(self, action: #selector(didHitPatrolButton), for: .touchUpInside)
        rootView.cancelButton.addTarget(self, action: #selector(didHitCancelButton), for: .touchUpInside)
        rootView.exitButton.addTarget(self, action: #selector(didHitExitButton), for: .touchUpInside)
        rootView.minimizeButton.addTarget(self, action: #selector(didHitMinimizeButton), for: .touchUpInside)
        rootView.imagePhoneButton.addTarget(self, action: #selector(didHitPhoneButton), for: .touchUpInside)
        rootView.textPhoneButton.addTarget(self, action: #selector(didHitPhoneButton), for: .touchUpInside)
        rootView.segmentedControl.addTarget(self, action: #selector(didChangeMode), for: .valueChanged)
    }

    @objc func didChangeMode() {
        presenter.didChangeMode(mode: rootView.segmentedControl.selectedSegmentIndex)
    }

    @objc func didHitAlarmButton(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            presenter.didHitAlarmButton()
        }
    }

    @objc func didHitTestButton() {
        presenter.didHitTestButton()
    }

    @objc func didHitPatrolButton() {
        presenter.didHitPatrolButton()
    }

    @objc func didHitCancelButton() {
        presenter.didHitCancelButton()
    }

    @objc func didHitExitButton() {
        presenter.didHitExitButton()
    }

    @objc func didHitMinimizeButton() {
        self.vibrate()

        UIControl().sendAction(
            #selector(URLSessionTask.suspend),
            to: UIApplication.shared,
            for: nil
        )
    }

    @objc func didHitPhoneButton() {
        presenter.didHitPhoneButton()
    }
}

// MARK: MainContract.View

extension MainViewController: MainContract.View {
    func setModeControlSelectedIndex(_ index: Int) {
        DispatchQueue.main.async {
            self.rootView.segmentedControl.selectedSegmentIndex = index
        }
    }

    func setModeControlEnabled(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.rootView.segmentedControl.isEnabled = enabled
        }
    }

    func setModeControlHidden(_ hidden: Bool) {
        DispatchQueue.main.async {
            self.rootView.segmentedControl.isHidden = hidden
        }
    }

    func setImagePhoneButtonHidden(_ hidden: Bool) {
        DispatchQueue.main.async {
            self.rootView.imagePhoneButton.isHidden = hidden
        }
    }

    func setTextPhoneButtonHidden(_ hidden: Bool) {
        DispatchQueue.main.async {
            self.rootView.textPhoneButton.isHidden = hidden
        }
    }

    func setTestButtonHidden(_ hidden: Bool) {
        DispatchQueue.main.async {
            self.rootView.testButton.isHidden = hidden
        }
    }

    func setAlarmButtonHidden(_ hidden: Bool) {
        DispatchQueue.main.async {
            self.rootView.alarmButton.isHidden = hidden
        }
    }

    func setCancelButtonHidden(_ hidden: Bool) {
        DispatchQueue.main.async {
            self.rootView.cancelButton.isHidden = hidden
        }
    }

    func setPatrolButtonHidden(_ hidden: Bool) {
        DispatchQueue.main.async {
            self.rootView.patrolButton.isHidden = hidden
        }
    }

    func setErrorViewHidden(_ hidden: Bool) {
        DispatchQueue.main.async {
            self.rootView.errorMessageBackgroundView.isHidden = hidden
        }
    }

    func showSecurityCodePrompt() {
        let alert = UIAlertController(
            title: "enter_security_code".localized,
            message: "enter_security_code_message".localized,
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "cancel".localized, style: .default, handler: nil)

        let proceedAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let code = alert.textFields?.first?.text {
                self.presenter.didProvideSecurityCode(code)
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(proceedAction)

        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "security_code".localized
        }

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showConfirmationPrompt() {
        let alert = UIAlertController(
            title: "confirmation".localized,
            message: "confirm_exit_message".localized,
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "cancel".localized, style: .default, handler: nil)

        let proceedAction = UIAlertAction(title: "to_exit".localized, style: .default) { _ in
            self.presenter.didProvideConfirmation()
        }

        alert.addAction(cancelAction)
        alert.addAction(proceedAction)

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openLoginScreen() {
        let loginViewController = Container.shared.resolve(LoginContract.View.self)!
        let navigationController = NavigationController(rootViewController: loginViewController)

        DispatchQueue.main.async {
            self.present(navigationController, animated: true)
        }
    }

    func call(to url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showAlertDialog(
                title: "error".localized,
                message: "unable_to_open_url".localized
            )
        }
    }

    func vibrate() {
        DispatchQueue.main.async {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }

    func setErrorMessage(_ errorMessage: String) {
        DispatchQueue.main.async {
            self.rootView.errorMessageLabel.text = errorMessage
            self.rootView.errorMessageBackgroundView.isHidden = false
        }
    }

    func showAlertDialog(title: String, message: String, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: completion)
        alert.addAction(action)

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

}
