//
//  CheckConnectionRequest.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 08.02.2021.
//  Copyright © 2021 Rubeg NPO. All rights reserved.
//

import Foundation

class CheckConnectionRequest: Request {

    var type: RequestType {
        return .checkConnection
    }

    func toString() -> String {
        return "{\"$c$\":\"checkconnection\"}"
    }

}
