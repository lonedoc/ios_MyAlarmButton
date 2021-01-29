//
//  AlarmRequest.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 29.01.2021.
//  Copyright © 2021 Rubeg NPO. All rights reserved.
//

import Foundation

class AlarmRequest: Request {

    private let isTest: Bool

    init(isTest: Bool) {
        self.isTest = isTest
    }

    var type: RequestType {
        return .updateLocation
    }

    func toString() -> String {
        let test = isTest ? ",\"test\": 1" : ""
        return """
            {"$c$": "mobalarm","id": "879A8884-1D0C-444F-8003-765A747B5C76"\(test)}
            """
    }
}
