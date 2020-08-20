//
//  MainPresenter.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 27/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class MainPresenter {

    private weak var view: MainContract.View?
    private let cacheManager: CacheManager
    private let networkService: NetworkService
    private let locationService: LocationService

    private let ipAddresses: [String]
    @Atomic private var currentIpIndex = 0

    private let phone: String
    private let password: String

    private var isAlarmActive: Bool = false

    init(
        cacheManager: CacheManager,
        networkService: NetworkService,
        locationService: LocationService,
        phone: String,
        password: String,
        ipAddresses: [String],
        currentIpIndex: Int = 0
    ) {
        self.cacheManager = cacheManager
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

            view?.setAlarmButtonHidden(false)
            view?.setCancelButtonHidden(true)
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

    private func sendCancelAlarmRequest(code: String) {
        guard ipAddresses.count > 0 else {
            view?.showAlertDialog(
                title: "error".localized,
                message: "address_not_found_message".localized
            )
            return
        }

        let ipAddress = ipAddresses[currentIpIndex % ipAddresses.count]

        guard let address = try? InetAddress.create(address: ipAddress, port: 9010) else {
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

        guard let address = try? InetAddress.create(address: ipAddress, port: 9010) else {
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

}

// MARK: MainContract.Presenter

extension MainPresenter: MainContract.Presenter {

    func attach(view: MainContract.View) {
        self.view = view
    }

    func viewWillAppear() {
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
    }

    func didHitAlarmButton() {
        let addresses = ipAddresses
            .compactMap { try? InetAddress.create(address: $0, port: 9010) }

        locationService.startLocationSharing(
            addresses: addresses,
            initialAddressIndex: currentIpIndex
        )

        view?.setAlarmButtonHidden(true)
        view?.setCancelButtonHidden(false)
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

    func didProvideConfirmation() {
        cacheManager.clearCache()
        locationService.stopLocationSharing()

        view?.openLoginScreen()
    }

}
