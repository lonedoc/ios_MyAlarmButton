//
//  LoginPresenter.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 11/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import RubegProtocol_v2_0
import Foundation

private let queueId = "ru.rubeg38.alarmbutton.loginpresenterqueue"

class LoginPresenter {

    private weak var view: LoginContract.View?
    private let appDataRepository: AppDataRepository
    private let companiesGateway: CompaniesGateway
    private let networkService: NetworkService

    private let backgroundQueue = DispatchQueue(label: queueId, qos: .userInitiated)

    private let ipAddresses = ["94.177.183.4", "194.125.255.105"]

    private var countryCodes = ["", "+7", "+375", "+380"]
    private var companies = [Company]()

    private var selectedCity: String?
    private var selectedCompany: Company?
    private var selectedCountryCode: String?
    private var phoneNumber: String?

    private var currentIpIndex = 0

    init(appDataRepository: AppDataRepository, companiesGateway: CompaniesGateway, networkService: NetworkService) {
        self.appDataRepository = appDataRepository
        self.companiesGateway = companiesGateway
        self.networkService = networkService
    }

    @objc func didReceivePasswordRequestResult(notification: Notification) {
        guard let success = notification.object as? Bool else {
            return
        }

        if success {
            guard let company = selectedCompany else {
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
                ipAddresses: company.ipAddresses,
                currentIpIndex: currentIpIndex
            )
        } else {
            // TODO: Notify user
        }
    }

    private func loadCachedData() {
        view?.setCountryCodes(countryCodes)

        if let company = appDataRepository.getCompany() {
            selectedCity = company.city
            view?.setCity(company.city)

            selectedCompany = company
            view?.setCompany(company.name)
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

    private func loadData() {
        var lastResult: RequestResult?
        var index = 0

        repeat {
            let ipAddress = ipAddresses[index % ipAddresses.count]

            index += 1

            guard let address = try? InetAddress.create(ip: ipAddress, port: 8300) else {
                continue
            }

            let (result, data) = companiesGateway.getCompanies(address: address)

            guard result == .success else {
                if lastResult == result {
                    continue
                }

                lastResult = result

                let errorMessage: String

                switch result {
                case .networkError:
                    errorMessage = "network_error_message".localized
                case .parseError:
                    errorMessage = "parse_error_message".localized
                default:
                    errorMessage = "unknown_error_message".localized
                }

                self.view?.showAlertDialog(title: "error".localized, message: errorMessage)

                continue
            }

            companies = data

            break
        } while true
    }

    private func updateCachedData() {
        var cities = companies
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

            var companiesInCity = companies
                .filter { $0.city == city }
                .map { $0.name }
                .sorted()

            companiesInCity.insert("", at: 0)
            view?.setCompanies(companiesInCity)

            if let company = selectedCompany,
               let companyIndex = (companiesInCity.firstIndex { $0 == company.name })
            { // swiftlint:disable:this opening_brace
                view?.selectCompanyPickerRow(companyIndex)

                // Update ip list
                selectedCompany = companies.first { $0.city == city && $0.name == company.name }
            } else {
                selectedCompany = nil
                view?.setCompany("")
                view?.selectCompanyPickerRow(0)
            }
        } else {
            selectedCity = nil
            selectedCompany = nil

            view?.setCity("")
            view?.setCompany("")
            view?.setCompanies([""])
            view?.selectCityPickerRow(0)
            view?.selectCompanyPickerRow(0)
        }
    }

    private func sendPasswordRequest() {
        guard let company = selectedCompany else {
            view?.showAlertDialog(
                title: "error".localized,
                message: "address_not_found_message".localized
            )
            return
        }

        guard company.ipAddresses.count > 0 else {
            view?.showAlertDialog(
                title: "error".localized,
                message: "address_not_found_message".localized
            )
            return
        }

        let ipAddress = company.ipAddresses[currentIpIndex % company.ipAddresses.count]

        guard let address = try? InetAddress.create(ip: ipAddress, port: 9010) else {
            view?.showAlertDialog(
                title: "error".localized,
                message: "address_error_message".localized
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
                self.currentIpIndex += 1
                self.view?.showRetryDialog()
            }
        }
    }

    private func saveDataInCache() {
        if let company = selectedCompany {
            appDataRepository.set(company: company)
        }

        if let countryCode = selectedCountryCode {
            appDataRepository.set(countryCode: countryCode)
        }

        if let phone = phoneNumber {
            appDataRepository.set(phone: extractDigits(text: phone))
        }
    }

    private func isReadyForSubmit() -> Bool {
        return selectedCompany != nil && selectedCountryCode != nil && phoneNumberIsValid(phoneNumber)
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
            self.loadData()
            self.updateCachedData()

            self.view?.setSubmitButtonEnabled(self.isReadyForSubmit())
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
        view?.setCompany("")

        selectedCity = city
        selectedCompany = nil

        var companiesInCity = companies
            .filter { $0.city == city }
            .map { $0.name }
            .sorted()

        companiesInCity.insert("", at: 0)
        view?.setCompanies(companiesInCity)
        view?.selectCompanyPickerRow(0)

        view?.setSubmitButtonEnabled(isReadyForSubmit())
    }

    func didSelect(company: String) {
        view?.setCompany(company)
        selectedCompany = companies.first { $0.city == selectedCity && $0.name == company }
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
        sendPasswordRequest()
    }

}
