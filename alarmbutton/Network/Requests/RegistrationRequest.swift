//
//  RegistrationRequest.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 25/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class RegistrationRequest : Request {
    
    private let phone: String
    private let password: String
    
    init(phone: String, password: String) {
        self.phone = phone
        self.password = password
    }
    
    var type: RequestType {
        return .registration
    }
    
    func toString() -> String {
        return """
        {
            "$c$": "reg",
            "id": "879A8884-1D0C-444F-8003-765A747B5C76",
            "os": "ios",
            "online": "0",
            "keeplive": "10",
            "username": "\(phone)",
            "password": "\(password)"
        }
        """
    }
    
}
