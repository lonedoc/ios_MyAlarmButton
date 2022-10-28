//
//  GuardService.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 19.10.2022.
//  Copyright © 2022 Rubeg NPO. All rights reserved.
//

import Foundation

struct GuardService {
    let city: String
    let name: String
    let hosts: [String]

    init(city: String, name: String, hosts: [String]) {
        self.city = city
        self.name = name
        self.hosts = hosts
    }
}
