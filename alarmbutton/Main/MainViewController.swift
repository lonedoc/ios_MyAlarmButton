//
//  MainViewController.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 27/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit
import Swinject

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
        rootView.alarmButton.addTarget(self, action: #selector(didHitAlarmButton), for: .touchUpInside)
        rootView.cancelButton.addTarget(self, action: #selector(didHitCancelButton), for: .touchUpInside)
        rootView.exitButton.addTarget(self, action: #selector(didHitExitButton), for: .touchUpInside)
    }

    @objc func didHitAlarmButton() {
        presenter.didHitAlarmButton()
    }

    @objc func didHitCancelButton() {
        presenter.didHitCancelButton()
    }

    @objc func didHitExitButton() {
        presenter.didHitExitButton()
    }
}

// MARK: MainContract.View

extension MainViewController: MainContract.View {

    func setAlarmButtonHidden(_ value: Bool) {
        DispatchQueue.main.async {
            self.rootView.alarmButton.isHidden = value

            if !value {
                self.rootView.exitButton.setBackgroundColor(.errorColorDark, for: .normal)
            }
        }
    }

    func setCancelButtonHidden(_ value: Bool) {
        DispatchQueue.main.async {
            self.rootView.cancelButton.isHidden = value

            if !value {
                self.rootView.exitButton.setBackgroundColor(.secondaryColorDark, for: .normal)
            }
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

    func showAlertDialog(title: String, message: String, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: completion)
        alert.addAction(action)

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

}
