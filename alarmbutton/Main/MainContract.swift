//
//  MainContract.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 27/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit
import Foundation

protocol IMainView: UIViewController, AlertDialog {
    func setModeControlSelectedIndex(_ index: Int)
    func setModeControlHidden(_ hidden: Bool)
    func setModeControlEnabled(_ enabled: Bool)
    func setImagePhoneButtonHidden(_ hidden: Bool)
    func setTextPhoneButtonHidden(_ hidden: Bool)
    func setTestButtonHidden(_ hidden: Bool)
    func setAlarmButtonHidden(_ hidden: Bool)
    func setCancelButtonHidden(_ hidden: Bool)
    func setPatrolButtonHidden(_ hidden: Bool)
    func setErrorViewHidden(_ hidden: Bool)
    func setErrorMessage(_ errorMessage: String)
    func showSecurityCodePrompt()
    func showConfirmationPrompt()
    func openLoginScreen()
    func call(to url: URL)
    func vibrate()
}

protocol IMainPresenter {
    func attach(view: MainContract.View)
    func didChangeMode(mode: Int)
    func viewWillAppear()
    func viewWillDisappear()
    func didHitAlarmButton()
    func didHitTestButton()
    func didHitPatrolButton()
    func didHitCancelButton()
    func didHitExitButton()
    func didHitPhoneButton()
    func didProvideConfirmation()
    func didProvideSecurityCode(_ value: String)
}

enum MainContract {
    typealias View = IMainView
    typealias Presenter = IMainPresenter
}
