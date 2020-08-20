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
    func setAlarmButtonHidden(_ value: Bool)
    func setCancelButtonHidden(_ value: Bool)
    func showSecurityCodePrompt()
    func showConfirmationPrompt()
    func openLoginScreen()
}

protocol IMainPresenter {
    func attach(view: MainContract.View)
    func viewWillAppear()
    func viewWillDisappear()
    func didHitAlarmButton()
    func didHitCancelButton()
    func didHitExitButton()
    func didProvideConfirmation()
    func didProvideSecurityCode(_ value: String)
}

enum MainContract {
    typealias View = IMainView
    typealias Presenter = IMainPresenter
}
