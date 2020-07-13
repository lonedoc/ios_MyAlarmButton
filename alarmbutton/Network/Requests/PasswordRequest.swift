//
//  PasswordRequest.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 24/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class PasswordRequest : Request {
    
    private let phone: String
    
    init(phone: String) {
        self.phone = phone
    }
    
    func toString() -> String {
        return """
        {
            "$c$": "getpassword",
            "phone": "\(phone)"
        }
        """
    }
    
}
