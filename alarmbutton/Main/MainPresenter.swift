//
//  MainPresenter.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 27/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import RubegProtocol_v2_0
import Foundation

class MainPresenter {

    private weak var view: MainContract.View?
    private let appDataRepository: AppDataRepository
    private let networkService: NetworkService
    private let locationService: LocationService

    private let ipAddresses: [String]
    @Atomic private var currentIpIndex = 0

    private let phone: String
    private let password: String

    private var isLocal: Bool = false
    private var isAlarmActive: Bool = false
    @Atomic private var isTesting: Bool = false

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

    @objc func didReceiveCancelAlarmRequestResult(notification: Notification) {
        guard let result = notification.object as? CancelAlarmRequestResult else {
            return
        }

        if result == .ok {
            locationService.stopLocationSharing()
            view?.showAlarmButton()
            isAlarmActive = false
        } else if result == .wrongCode {
            view?.showAlertDialog(
                title: "wrong_code".localized,
                message: "wrong_code_message".localized
            )
        } else if result == .unknown {
            view?.showAlertDialog(
                title: "unknown_error".localized,
                message: "cancellation_failed_message".localized
            )
        }
    }

    @objc func didReceiveInvalidTokenMessage(notification: Notification) {
        sendRegistrationRequest()
    }

    @objc func didReceiveLocationResponse(notification: Notification) {
        if isTesting {
            isTesting = false
            locationService.stopLocationSharing()

            view?.showAlertDialog(
                title: "test_result_title".localized,
                message: "test_result_ok".localized
            )
            return
        }

        if isAlarmActive {
            return
        }

        isAlarmActive = true
        view?.showCancelButton()

        if isLocal {
            // TODO: Start timer
        }
    }

    private func sendCancelAlarmRequest(code: String) {
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

        let request = CancelAlarmRequest(
            code: code,
            latitude: locationService.lastLatitude ?? 0.0,
            longitude: locationService.lastLongitude ?? 0.0
        )

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
                self.view?.showAlertDialog(
                    title: "error".localized,
                    message: "network_error_message".localized
                )
            }
        }
    }

    private func sendRegistrationRequest() {
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
                self.currentIpIndex += 1
                self.sendRegistrationRequest()
            }
        }
    }

    private func sendAlarmRequest(test: Bool) {
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

        let request = AlarmRequest(isTest: test)

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
                self.currentIpIndex += 1
                self.sendAlarmRequest(test: test)
            }
        }
    }

}

// MARK: MainContract.Presenter

extension MainPresenter: MainContract.Presenter {

    func attach(view: MainContract.View) {
        self.view = view
    }

    func viewWillAppear() {
        self.isLocal = appDataRepository.getIsLocal() ?? false

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

    func viewWillDisappear() {
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

    func didHitAlarmButton() {
        isTesting = false

        if isLocal {
            sendAlarmRequest(test: isTesting)
            return
        }

        let addresses = ipAddresses
            .compactMap { try? InetAddress.create(ip: $0, port: 9010) }

        locationService.startLocationSharing(
            addresses: addresses,
            initialAddressIndex: currentIpIndex,
            isTest: false
        )
    }

    func didHitTestButton() {
        isTesting = true

        if isLocal {
            sendAlarmRequest(test: isTesting)
            return
        }

        let addresses = ipAddresses
            .compactMap { try? InetAddress.create(ip: $0, port: 9010) }

        locationService.startLocationSharing(
            addresses: addresses,
            initialAddressIndex: currentIpIndex,
            isTest: true
        )
    }

    func didHitCancelButton() {
        view?.showSecurityCodePrompt()
    }

    func didHitExitButton() {
        view?.showConfirmationPrompt()
    }

    func didProvideSecurityCode(_ value: String) {
        sendCancelAlarmRequest(code: value)
    }

    func didHitPhoneButton() {
        guard let phone = appDataRepository.getSecurityPhone() else {
            view?.showAlertDialog(
                title: "error".localized,
                message: "phone_number_not_found".localized
            )
            return
        }

        guard let url = URL(string: "tel://+7\(phone)") else { return }

        view?.call(to: url)
    }

    func didProvideConfirmation() {
        appDataRepository.clearCache()
        locationService.stopLocationSharing()

        view?.openLoginScreen()
    }

}
