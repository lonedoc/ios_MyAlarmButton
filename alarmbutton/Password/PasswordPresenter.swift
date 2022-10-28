//
//  PasswordPresenter.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 22/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import RubegProtocol_v2_0
import Foundation

private let passwordRequestCode = 0
private let registrationRequestCode = 1

class PasswordPresenter {

    private weak var view: PasswordContract.View?
    private let appDataRepository: AppDataRepository
    private let networkService: NetworkService

    private var timer: Timer?
    private var timeLeft: Int = 120

    private let addresses: [InetAddress]
    @Atomic private var currentAddressIndex = 0

    private let phone: String
    private var password: String?

    init(
        appDataRepository: AppDataRepository,
        networkService: NetworkService,
        phone: String,
        addresses: [InetAddress],
        currentAddressIndex: Int = 0
    ) {
        self.appDataRepository = appDataRepository
        self.networkService = networkService
        self.phone = phone
        self.addresses = addresses
        self.currentAddressIndex = currentAddressIndex
    }

    @objc func didReceivePasswordRequestResult(notification: Notification) {
        guard let success = notification.object as? Bool else {
            return
        }

        if success {
            startTimer()
        } else {
            // TODO: Notify user
        }
    }

    @objc func didReceiveRegistrationResult(_ notification: Notification) {
        guard let password = password else {
            return
        }

        appDataRepository.set(password: password)

        if networkService.isStarted {
            networkService.stop()
        }

        view?.openMainScreen(
            phone: phone,
            password: password,
            addresses: addresses,
            currentAddressIndex: currentAddressIndex
        )
    }

    private func startTimer() {
        timeLeft = 120

        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func updateTimer() {
        if timeLeft > 0 {
            timeLeft -= 1
        } else {
            timer?.invalidate()
            return
        }

        let label = "time_left".localized
        let time = getStringRepresentationOf(time: timeLeft)
        view?.updateTimer(text: "\(label) \(time)")
    }

    private func getStringRepresentationOf(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }

    private func sendPasswordRequest() {
        guard addresses.count > 0 else {
            view?.showAlertDialog(
                title: "error".localized,
                message: "address_not_found_message".localized
            )
            return
        }

        let address = addresses[currentAddressIndex % addresses.count]
        let request = PasswordRequest(phone: extractDigits(text: phone))

        if !networkService.isStarted {
            do {
                try networkService.start()
            } catch let error {
                view?.showAlertDialog(
                    title: "error".localized,
                    message: "connection_error_message".localized
                )

                print(error.localizedDescription)
                return
            }
        }

        networkService.send(request: request, to: address) { success in
            if !success {
                self.view?.showRetryDialog(code: passwordRequestCode)
            }
        }
    }

    private func sendRegistrationRequest() {
        guard addresses.count > 0 else {
            view?.showAlertDialog(
                title: "error".localized,
                message: "address_not_found_message".localized
            )
            return
        }

        let address = addresses[currentAddressIndex % addresses.count]

        guard let password = password else {
            // TODO: Show error message
            return
        }

        let request = RegistrationRequest(phone: phone, password: password)

        if !networkService.isStarted {
            do {
                try networkService.start()
            } catch let error {
                view?.showAlertDialog(
                    title: "error".localized,
                    message: "connection_error_message".localized
                )

                print(error.localizedDescription)
                return
            }
        }

        networkService.send(request: request, to: address) { success in
            if !success {
                self.currentAddressIndex += 1
                self.view?.showRetryDialog(code: registrationRequestCode)
            }
        }
    }

    private func extractDigits(text: String) -> String {
        return text.filter { isDigit($0) }
    }

    private func isDigit(_ character: Character) -> Bool {
        return "0123456789".contains(character)
    }

    private func validatePassword(_ value: String) -> Bool {
        let correctLength = value.count > 0
        let correctCharacters = value.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil

        return correctLength && correctCharacters
    }

}

// MARK: PasswordContract.Presenter

extension PasswordPresenter: PasswordContract.Presenter {

    func attach(view: PasswordContract.View) {
        self.view = view
    }

    func viewDidLoad() {
        startTimer()
    }

    func viewWillAppear() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveRegistrationResult),
            name: .didReceiveRegistrationResult,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceivePasswordRequestResult(notification:)),
            name: .didReceivePasswordRequestResult,
            object: nil
        )
    }

    func viewWillDisappear() {
        NotificationCenter.default.removeObserver(
            self,
            name: .didReceiveRegistrationResult,
            object: nil
        )

        NotificationCenter.default.removeObserver(
            self,
            name: .didReceivePasswordRequestResult,
            object: nil
        )
    }

    func didChangePassword(value: String) {
        password = value
        let proceedButtonEnabled = validatePassword(value)
        view?.setProceedButtonEnabled(proceedButtonEnabled)
    }

    func didHitRetryButton(code: Int) {
        if code == passwordRequestCode {
            sendPasswordRequest()
        } else if code == registrationRequestCode {
            sendRegistrationRequest()
        }
    }

    func didHitProceedButton() {
        sendRegistrationRequest()
    }

    func didHitCancelButton() {
        view?.openLoginScreen()
    }

}
