//
//  NotificationNames.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 26/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didReceiveRegistrationResult = Notification.Name("didReceiveRegistrationResult")
    static let didReceivePasswordRequestResult = Notification.Name("didReceivePasswordRequestResult")
    static let didReceiveCancelAlarmRequestResult = Notification.Name("didReceiveCancelAlarmRequestResult")
    static let didReceiveInvalidTokenMessage = Notification.Name("didReceiveInvalidTokenMessage")
}
