//
//  UpdateLocationRequest.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 28/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class UpdateLocationRequest : Request {
    
    private let latitude: Double
    private let longitude: Double
    private let accuracy: Double
    private let speed: Double
    
    init(latitude: Double, longitude: Double, accuracy: Double, speed: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
        self.speed = speed
    }
    
    func toString() -> String {
        return """
        {
            "$c$": "mobalarm",
            "id": "879A8884-1D0C-444F-8003-765A747B5C76",
            "lat": \(latitude),
            "lon": \(longitude),
            "accuracy": \(accuracy),
            "speed": \(speed)
        }
        """
    }
    
}
