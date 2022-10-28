//
//  GuardServicesDto.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 19.10.2022.
//  Copyright © 2022 Rubeg NPO. All rights reserved.
//

import Foundation

struct GuardServicesDto: Decodable {
    let data: [CityDto]

    enum CodingKeys: String, CodingKey {
        case data = "city"
    }

    static func parse(json: String) throws -> GuardServicesDto {
        return try JSONDecoder().decode(GuardServicesDto.self, from: json.data(using: .utf8)!)
    }
}
