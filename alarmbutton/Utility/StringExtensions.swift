//
//  LocalizedString.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 01/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
