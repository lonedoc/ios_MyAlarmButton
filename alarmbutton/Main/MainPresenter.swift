//
//  MainPresenter.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 27/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import RubegProtocol_v2_0
import Foundation

enum MainViewState {
    case idle, alert, patrol, blocked
}

class MainPresenter {
    private weak var view: MainContract.View?
    private var viewState: MainViewState = .idle

    private let appDataRepository: AppDataRepository
    private let networkService: NetworkService
    private let locationService: LocationService

    private let phone: String
    private let password: String

    private let ipAddresses: [String]
    @Atomic private var currentIpIndex = 0

    private var isLocal = false
    private var patrolModeTimeout = 0

    @Atomic private var onAlarm = false
    @Atomic private var onTest = false
    @Atomic private var onPatrol = false

    private var patrolModeTimer: Timer?
    private var localAlarmTimer: Timer?

    init(
        appDataRepository: AppDataRepository,
        networkService: NetworkService,
        locationService: LocationService,
        phone: String,
        password: String,
        ipAddresses: [String],
        currentIpIndex: Int = 0
    ) {
        self.appDataRepository = appDataRepository
        self.networkService = networkService
        self.locationService = locationService
        self.phone = phone
        self.password = password
        self.ipAddresses = ipAddresses
        self.currentIpIndex = currentIpIndex
    }

    private func startLocationService(onTest: Bool, onPatrol: Bool) {
        let addresses = ipAddresses
            .compactMap { try? InetAddress.create(ip: $0, port: 9010) }

        locationService.startLocationSharing(
            addresses: addresses,
            initialAddressIndex: currentIpIndex,
            isTest: onTest,
            isPatrol: onPatrol
        )
    }
}

// MARK: Network requests

extension MainPresenter {
    private func send(request: Request, retry: Int = 0) {
        guard ipAddresses.count > 0 else {
            view?.showAlertDialog(
                title: "error".localized,
                message: "address_not_found_message".localized
            )
            return
        }

        let ipAddress = ipAddresses[currentIpIndex % ipAddresses.count]

        guard let address = try? InetAddress.create(ip: ipAddress, port: 9010) else {
            view?.showAlertDialog(
                title: "error".localized,
                message: "address_error_message".localized
            )
            return
        }

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
                if retry > 0 {
                    self.currentIpIndex += 1
                    self.send(request: request, retry: retry - 1)
                    return
                }

                self.view?.showAlertDialog(
                    title: "error".localized,
                    message: "network_error_message".localized
                )
            }
        }
    }
}

// MARK: View state

extension MainPresenter {
    private func setViewState(_ state: MainViewState) {
        // TODO: Reduce switch
        switch state {
        case .idle:
            view?.setAlarmButtonHidden(false)
            view?.setCancelButtonHidden(true)
            view?.setPatrolButtonHidden(true)
            view?.setImagePhoneButtonHidden(false)
            view?.setTextPhoneButtonHidden(true)
            view?.setTestButtonHidden(false)
            view?.setErrorViewHidden(true)
        case .alert:
            view?.setAlarmButtonHidden(true)
            view?.setCancelButtonHidden(false)
            view?.setPatrolButtonHidden(true)
            view?.setImagePhoneButtonHidden(false)
            view?.setTextPhoneButtonHidden(true)
            view?.setTestButtonHidden(false)
            view?.setErrorViewHidden(true)
        case .patrol:
            view?.setAlarmButtonHidden(true)
            view?.setCancelButtonHidden(true)
            view?.setPatrolButtonHidden(false)
            view?.setImagePhoneButtonHidden(true)
            view?.setTextPhoneButtonHidden(false)
            view?.setTestButtonHidden(true)
            view?.setErrorViewHidden(true)
        case .blocked:
            view?.setAlarmButtonHidden(false)
            view?.setCancelButtonHidden(true)
            view?.setPatrolButtonHidden(true)
            view?.setImagePhoneButtonHidden(false)
            view?.setTextPhoneButtonHidden(true)
            view?.setTestButtonHidden(false)
            view?.setErrorViewHidden(false)
        }
    }
}

// MARK: Notifications

extension MainPresenter {
    private func subscribeForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveAccountBlockedMessage(notification:)),
            name: .didReceiveAccountBlockedMessage,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceivePatrolModeTimeoutValue(notification:)),
            name: .didReceivePatrolModeTimeoutValue,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveCancelAlarmRequestResult(notification:)),
            name: .didReceiveCancelAlarmRequestResult,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveInvalidTokenMessage(notification:)),
            name: .didReceiveInvalidTokenMessage,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveLocationResponse(notification:)),
            name: .didReceiveLocationResponse,
            object: nil
        )
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: .didReceiveAccountBlockedMessage,
            object: nil
        )

        NotificationCenter.default.removeObserver(
            self,
            name: .didReceivePatrolModeTimeoutValue,
            object: nil
        )

        NotificationCenter.default.removeObserver(
            self,
            name: .didReceiveCancelAlarmRequestResult,
            object: nil
        )

        NotificationCenter.default.removeObserver(
            self,
            name: .didReceiveInvalidTokenMessage,
            object: nil
        )

        NotificationCenter.default.removeObserver(
            self,
            name: .didReceiveLocationResponse,
            object: nil
        )
    }

    @objc func didReceiveAccountBlockedMessage(notification: Notification) {
        let description =
            notification.userInfo?["description"] as? String ?? "Учетная запись заблокирована"

        view?.setErrorMessage(description)
    }

    @objc func didReceivePatrolModeTimeoutValue(notification: Notification) {
        patrolModeTimeout = notification.userInfo?["timeout"] as? Int ?? 0
    }

    @objc func didReceiveLocationResponse(notification: Notification) {
        if onPatrol {
            onPatrol = false
            locationService.stopLocationSharing()

            view?.showAlertDialog(
                title: "patrol_result_title".localized,
                message: "patrol_result_ok".localized
            )

            return
        }

        if onTest {
            onTest = false
            locationService.stopLocationSharing()

            view?.showAlertDialog(
                title: "test_result_title".localized,
                message: "test_result_ok".localized
            )

            return
        }

        if onAlarm {
            return
        }

        onAlarm = true
        viewState = .alert
        setViewState(viewState)

        if isLocal {
            DispatchQueue.main.async {
                self.localAlarmTimer?.invalidate()
                self.localAlarmTimer = Timer.scheduledTimer(
                    withTimeInterval: 30,
                    repeats: false
                ) { [weak self] _ in
                    self?.viewState = .idle
                    self?.setViewState(.idle)
                    self?.view?.setModeControlEnabled(true)
                }
            }
        }
    }

    @objc func didReceiveCancelAlarmRequestResult(notification: Notification) {
        guard let result = notification.userInfo?["result"] as? CancelAlarmRequestResult else {
            return
        }

        switch result {
        case .ok:
            locationService.stopLocationSharing()

            viewState = .idle
            setViewState(viewState)
            view?.setModeControlEnabled(true)

            onAlarm = false
        case .wrongCode:
            view?.showAlertDialog(
                title: "wrong_code".localized,
                message: "wrong_code_message".localized
            )
        case .unknown:
            view?.showAlertDialog(
                title: "unknown_error".localized,
                message: "cancellation_failed_message".localized
            )
        }
    }

    @objc func didReceiveInvalidTokenMessage(notification: Notification) {
        let request = RegistrationRequest(phone: phone, password: password)
        send(request: request, retry: 10)
    }
}

// MARK: MainContract.Presenter

extension MainPresenter: MainContract.Presenter {
    func attach(view: MainContract.View) {
        self.view = view
    }

    func viewWillAppear() {
        subscribeForNotifications()

        setViewState(viewState)

        let patrolModeEnabled = appDataRepository.getPatrolMode() ?? false
        view?.setModeControlHidden(!patrolModeEnabled)

        isLocal = appDataRepository.getIsLocal() ?? false

        let request = CheckConnectionRequest()
        send(request: request, retry: 10)
    }

    func viewWillDisappear() {
        unsubscribeFromNotifications()
    }

    func didChangeMode(mode: Int) {
        patrolModeTimer?.invalidate()

        if mode == 1 {
            if patrolModeTimeout > 0 {
                patrolModeTimer = Timer.scheduledTimer(
                    withTimeInterval: Double(patrolModeTimeout),
                    repeats: false
                ) { [weak self] _ in
                    if self?.viewState == .patrol {
                        self?.view?.setModeControlSelectedIndex(0)
                        self?.viewState = .idle
                        self?.setViewState(.idle)
                    }
                }
            }
        }

        viewState = mode == 0 ? .idle : .patrol
        setViewState(viewState)
    }

    func didHitAlarmButton() {
        view?.vibrate()

        onTest = false

        if isLocal {
            let request = AlarmRequest(isTest: false)
            send(request: request, retry: 5)
            return
        }

        startLocationService(onTest: false, onPatrol: false)
        view?.setModeControlEnabled(false)
    }

    func didHitTestButton() {
        view?.vibrate()

        onTest = true

        if isLocal {
            let request = AlarmRequest(isTest: true)
            send(request: request, retry: 5)
            return
        }

        startLocationService(onTest: true, onPatrol: false)
    }

    func didHitPatrolButton() {
        view?.vibrate()

        onPatrol = true
        startLocationService(onTest: false, onPatrol: true)
    }

    func didHitCancelButton() {
        view?.vibrate()

        if !isLocal {
            view?.showSecurityCodePrompt()
        }
    }

    func didHitExitButton() {
        view?.vibrate()
        view?.showConfirmationPrompt()
    }

    func didHitPhoneButton() {
        view?.vibrate()

        guard let phone = appDataRepository.getSecurityPhone() else {
            view?.showAlertDialog(
                title: "error".localized,
                message: "phone_number_not_found".localized
            )
            return
        }

        guard let url = URL(string: "tel://\(phone)") else { return }

        view?.call(to: url)
    }

    func didProvideConfirmation() {
        appDataRepository.clearCache()
        locationService.stopLocationSharing()

        view?.openLoginScreen()
    }

    func didProvideSecurityCode(_ value: String) {
        let request = CancelAlarmRequest(
            code: value,
            latitude: locationService.lastLatitude ?? 0.0,
            longitude: locationService.lastLongitude ?? 0.0
        )
        send(request: request)
    }
}
