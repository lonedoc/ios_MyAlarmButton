//
//  AlertDialog.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 18/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit

protocol AlertDialog { // TODO: Find more apropriate name
    func showAlertDialog(title: String, message: String, completion: ((UIAlertAction) -> Void)?)
}

extension AlertDialog {
    func showAlertDialog(title: String, message: String) {
        showAlertDialog(title: title, message: message, completion: nil)
    }
}
