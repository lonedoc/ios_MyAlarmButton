//
//  LoginPresenter.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 11/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import RubegProtocol_v2_0
import Foundation
import RxSwift

private let queueId = "ru.rubeg38.alarmbutton.loginpresenterqueue"

class LoginPresenter {

    private weak var view: LoginContract.View?
    private let appDataRepository: AppDataRepository
    private let guardServicesGateway: GuardServicesGateway
    private let networkService: NetworkService

    private let backgroundQueue = DispatchQueue(label: queueId, qos: .userInitiated)
    private let disposeBag = DisposeBag()

    private var countryCodes = ["", "+7", "+375", "+380"]
    private var guardServices = [GuardService]()

    private var selectedCity: String?
    private var selectedCountryCode: String?
    private var phoneNumber: String?

    private var selectedGuardService: GuardService? {
        didSet {
            addresses = []
            currentAddressIndex = 0
        }
    }

    private var addresses = [InetAddress]()
    private var currentAddressIndex = 0

    init(appDataRepository: AppDataRepository, companiesGateway: GuardServicesGateway, networkService: NetworkService) {
        self.appDataRepository = appDataRepository
        self.guardServicesGateway = companiesGateway
        self.networkService = networkService
    }

    @objc func didReceivePasswordRequestResult(notification: Notification) {
        guard let success = notification.object as? Bool else {
            return
        }

        if success {
            guard let guardService = selectedGuardService else {
                view?.showAlertDialog(
                    title: "error".localized,
                    message: "company_not_found_message".localized
                )
                return
            }

            guard let phone = phoneNumber else {
                view?.showAlertDialog(
                    title: "error".localized,
                    message: "phone_number_not_found_message".localized
                )
                return
            }

            if networkService.isStarted {
                networkService.stop()
            }

            view?.openPasswordScreen(
                phone: extractDigits(text: phone),
                addresses: addresses,
                currentAddressIndex: currentAddressIndex
            )
        } else {
            // TODO: Notify user
        }
    }

    private func loadCachedData() {
        view?.setCountryCodes(countryCodes)

        if let guardService = appDataRepository.getGuardService() {
            selectedCity = guardService.city
            view?.setCity(guardService.city)

            selectedGuardService = guardService
            view?.setGuardService(guardService.name)
        }

        if let countryCode = appDataRepository.getCountryCode() {
            if let index = countryCodes.firstIndex(of: countryCode) {
                selectedCountryCode = countryCode
                view?.setCountryCode(countryCode)
                view?.selectCountryCodePickerRow(index)
            }
        }

        if let phone = appDataRepository.getPhone() {
            phoneNumber = phone
            view?.setPhoneNumber(PhoneMask().apply(to: phone))
        }
    }

    private func loadData(_ completion: @escaping () -> Void) {
        self.guardServicesGateway.getGuardServices()
            .subscribe(
                onNext: { [weak self] guardServices in
                    self?.guardServices = guardServices
                    completion()
                },
                onError: { [weak self] error in
                    self?.view?.showAlertDialog(title: "error".localized, message: error.localizedDescription)
                    completion()
                }
            )
            .disposed(by: self.disposeBag)
    }

    private func updateCachedData() {
        var cities = guardServices
            .map { $0.city }
            .distinct { $0 == $1 }
            .sorted()

        cities.insert("", at: 0)

        self.view?.setCities(cities)

        if
            let city = selectedCity,
            let index = cities.firstIndex(of: city)
        {
            view?.selectCityPickerRow(index)

            var guardServicesInCity = guardServices
                .filter { $0.city == city }
                .map { $0.name }
                .sorted()

            guardServicesInCity.insert("", at: 0)
            view?.setGuardServices(guardServicesInCity)

            if let guardService = selectedGuardService,
               let guardServiceIndex = (guardServicesInCity.firstIndex { $0 == guardService.name })
            { // swiftlint:disable:this opening_brace
                view?.selectGuardServicePickerRow(guardServiceIndex)
                selectedGuardService = guardServices.first { $0.city == city && $0.name == guardService.name }
            } else {
                selectedGuardService = nil
                view?.setGuardService("")
                view?.selectGuardServicePickerRow(0)
            }
        } else {
            selectedCity = nil
            selectedGuardService = nil

            view?.setCity("")
            view?.setGuardService("")
            view?.setGuardServices([""])
            view?.selectCityPickerRow(0)
            view?.selectGuardServicePickerRow(0)
        }
    }

    private func sendPasswordRequest() {
        guard let address = prepareAddress() else {
            view?.showAlertDialog(
                title: "error".localized,
                message: "address_not_found_message".localized
            )
            return
        }

        guard let phone = phoneNumber else {
            view?.showAlertDialog(
                title: "error".localized,
                message: "phone_number_not_found_message".localized
            )
            return
        }

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
                self.view?.showRetryDialog()
            }
        }
    }

    private func prepareAddress() -> InetAddress? {
        if addresses.isEmpty {
            guard let guardService = selectedGuardService else {
                return nil
            }

            addresses = InetAddress.createAll(hosts: guardService.hosts, port: 9010)
        }

        if addresses.isEmpty {
            return nil
        }

        return addresses[currentAddressIndex % addresses.count]
    }

    private func saveDataInCache() {
        if let guardService = selectedGuardService {
            appDataRepository.set(guardService: guardService)
        }

        if let countryCode = selectedCountryCode {
            appDataRepository.set(countryCode: countryCode)
        }

        if let phone = phoneNumber {
            appDataRepository.set(phone: extractDigits(text: phone))
        }
    }

    private func isReadyForSubmit() -> Bool {
        return selectedGuardService != nil && selectedCountryCode != nil && phoneNumberIsValid(phoneNumber)
    }

    private func phoneNumberIsValid(_ value: String?) -> Bool {
        guard let value = value else {
            return false
        }

        return extractDigits(text: value).count == 10
    }

    private func extractDigits(text: String) -> String {
        return text.filter { isDigit($0) }
    }

    private func isDigit(_ character: Character) -> Bool {
        return "0123456789".contains(character)
    }

}

// MARK: LoginContract.Presenter

extension LoginPresenter: LoginContract.Presenter {

    func attach(view: LoginContract.View) {
        self.view = view
    }

    func viewDidLoad() {
        backgroundQueue.async {
            self.loadCachedData()
            self.loadData {
                self.updateCachedData()
                self.view?.setSubmitButtonEnabled(self.isReadyForSubmit())
            }
        }
    }

    func viewWillAppear() {
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
            name: .didReceivePasswordRequestResult,
            object: nil
        )
    }

    func didSelect(city: String) {
        view?.setCity(city)
        view?.setGuardService("")

        selectedCity = city
        selectedGuardService = nil

        var guardServicesInCity = guardServices
            .filter { $0.city == city }
            .map { $0.name }
            .sorted()

        guardServicesInCity.insert("", at: 0)
        view?.setGuardServices(guardServicesInCity)
        view?.selectGuardServicePickerRow(0)

        view?.setSubmitButtonEnabled(isReadyForSubmit())
    }

    func didSelect(guardService: String) {
        view?.setGuardService(guardService)
        selectedGuardService = guardServices.first { $0.city == selectedCity && $0.name == guardService }
        view?.setSubmitButtonEnabled(isReadyForSubmit())
    }

    func didSelect(countryCode: String) {
        view?.setCountryCode(countryCode)
        selectedCountryCode = countryCode
    }

    func didChangePhone(value: String) {
        let phoneMask = PhoneMask()

        if phoneMask.validatePart(value) {
            phoneNumber = value
            view?.setPhoneNumber(value)
        } else {
            let formattedValue = phoneMask.apply(to: value)
            phoneNumber = formattedValue
            view?.setPhoneNumber(formattedValue)
        }

        view?.setSubmitButtonEnabled(isReadyForSubmit())
    }

    func didHitSubmitButton() {
        saveDataInCache()
        sendPasswordRequest()
    }

    func didHitRetryButton() {
        currentAddressIndex += 1
        sendPasswordRequest()
    }

}
