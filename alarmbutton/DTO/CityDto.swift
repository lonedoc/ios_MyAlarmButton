//
//  CityDto.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 19.10.2022.
//  Copyright © 2022 Rubeg NPO. All rights reserved.
//

import Foundation

struct CityDto: Decodable {
    let name: String
    let guardServices: [GuardServiceDto]

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case guardServices = "pr"
    }
}
