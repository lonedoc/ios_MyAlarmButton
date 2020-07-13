//
//  Company.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 17/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class Company {
    
    let city: String
    let name: String
    let ip: [String]
    
    init(city: String, name: String, ip: [String]) {
        self.city = city
        self.name = name
        self.ip = ip
    }
    
}
