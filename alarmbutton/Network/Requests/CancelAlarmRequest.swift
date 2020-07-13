//
//  CancelAlarmRequest.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 28/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class CancelAlarmRequest : Request {
    
    private let code: String
    private let latitude: Double
    private let longitude: Double
    
    init(code: String, latitude: Double, longitude: Double) {
        self.code = code
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func toString() -> String {
        return """
        {
            "$c$": "cancelalarm",
            "id": "879A8884-1D0C-444F-8003-765A747B5C76",
            "code": "\(code)",
            "lat": \(latitude),
            "lon": \(longitude)
        }
        """
    }
    
}
