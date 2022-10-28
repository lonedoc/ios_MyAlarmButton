//
//  LoginContract.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 12/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit
import Foundation
import RubegProtocol_v2_0

protocol ILoginView: UIViewController, AlertDialog {
    func setCities(_ cities: [String])
    func setGuardServices(_ guardServices: [String])
    func setCountryCodes(_ countryCodes: [String])
    func selectCityPickerRow(_ row: Int)
    func selectGuardServicePickerRow(_ row: Int)
    func selectCountryCodePickerRow(_ row: Int)
    func setCity(_ value: String)
    func setGuardService(_ value: String)
    func setCountryCode(_ value: String)
    func setPhoneNumber(_ value: String)
    func setSubmitButtonEnabled(_ enabled: Bool)
    func showRetryDialog()
    func openPasswordScreen(phone: String, addresses: [InetAddress], currentAddressIndex: Int)
}

protocol ILoginPresenter {
    func attach(view: LoginContract.View)
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func didSelect(city: String)
    func didSelect(guardService: String)
    func didSelect(countryCode: String)
    func didChangePhone(value: String)
    func didHitSubmitButton()
    func didHitRetryButton()
}

enum LoginContract {
    typealias View = ILoginView
    typealias Presenter = ILoginPresenter
}
