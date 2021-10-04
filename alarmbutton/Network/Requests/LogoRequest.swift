//
//  LogoRequest.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 04.10.2021.
//  Copyright © 2021 Rubeg NPO. All rights reserved.
//

import Foundation

struct LogoRequest: Request {
    private let size: Int

    init(size: Int) {
        self.size = size
    }

    var type: RequestType {
        return .logo
    }

    func toString() -> String {
        return """
            {"$c$": "getlogo","size": \(size)}
            """
    }
}
