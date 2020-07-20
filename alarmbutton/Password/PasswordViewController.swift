//
//  PasswordViewController.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 22/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit
import Swinject

class PasswordViewController : UIViewController {
    
    private let presenter: PasswordContract.Presenter
    private var rootView: PasswordView { return self.view as! PasswordView }
    
    init(with presenter: PasswordContract.Presenter) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
        self.title = "registration".localized
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = PasswordView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        presenter.attach(view: self)
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
        
        registerForKeyboardNotifications()
        configureInputControls()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        presenter.viewWillDisappear()
        
        unregisterForKeyboardNotifications()
    }
    
    private func configureInputControls() {
        rootView.doneButtonItem.target = self
        rootView.doneButtonItem.action = #selector(endInput)
        
        rootView.passwordTextField.delegate = self
        
        rootView.cancelButton.addTarget(self, action: #selector(didHitCancelButton), for: .touchUpInside)
        rootView.proceedButton.addTarget(self, action: #selector(didHitProceedButton), for: .touchUpInside)
    }
    
    @objc func endInput() {
        rootView.passwordTextField.resignFirstResponder()
    }
    
    @objc func didHitCancelButton() {
        presenter.didHitCancelButton()
    }
    
    @objc func didHitProceedButton() {
        presenter.didHitProceedButton()
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
    
        rootView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        rootView.scrollView.scrollIndicatorInsets = rootView.scrollView.contentInset
    }
    
    @objc func keyboardWillHide(_: Notification) {
        rootView.scrollView.contentInset = .zero
        rootView.scrollView.scrollIndicatorInsets = rootView.scrollView.contentInset
    }
    
}

// MARK: UITextFieldDelegate

extension PasswordViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == rootView.passwordTextField else {
            return true
        }
        
        if
            let text = textField.text,
            let textRange = Range(range, in: text)
        {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            presenter.didChangePassword(value: updatedText)
        }
        
        return true
    }
    
}

// MARK: PasswordContract.View

extension PasswordViewController : PasswordContract.View {
    
    func updateTimer(text: String) {
        DispatchQueue.main.async {
            self.rootView.timeLeftLabel.text = text
        }
    }
    
    func setProceedButtonEnabled(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.rootView.proceedButton.isEnabled = enabled
        }
    }
    
    func showRetryDialog(code: Int) {
        let alert = UIAlertController(
            title: "error".localized,
            message: "network_error_message".localized,
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .default, handler: nil)
        
        let retryAction = UIAlertAction(title: "retry".localized, style: .default) { _ in
            self.presenter.didHitRetryButton(code: code)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openMainScreen(phone: String, password: String, ip: [String], currentIpIndex: Int) {
        DispatchQueue.main.async {
            let mainViewController = Container.shared.resolve(
                MainContract.View.self,
                arguments: phone, password, ip, 0
            )!
            
            self.present(mainViewController, animated: true)
        }
    }
    
    func openLoginScreen() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
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
