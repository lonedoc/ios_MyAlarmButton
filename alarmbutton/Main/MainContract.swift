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
    func showAlarmButton()
    func showCancelButton()
    func showSecurityCodePrompt()
    func showConfirmationPrompt()
    func openLoginScreen()
    func call(to url: URL)
}

protocol IMainPresenter {
    func attach(view: MainContract.View)
    func viewWillAppear()
    func viewWillDisappear()
    func didHitAlarmButton()
    func didHitTestButton()
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
