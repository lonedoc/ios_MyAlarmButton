//
//  InetAddress.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 17/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class InetAddress {
    
    let address: String
    let port: Int32
    
    static func create(address addressValue: String, port portValue: Int32) throws -> InetAddress {
        try validate(address: addressValue)
        try validate(port: portValue)
        
        return InetAddress(address: addressValue, port: portValue)
    }
    
    private init(address addressValue: String, port portValue: Int32) {
        address = addressValue
        port = portValue
    }
    
    private static func validate(address: String) throws {
        // TODO: validate address value
//        throw fatalError("not yet implemented")
    }
    
    private static func validate(port: Int32) throws {
        // TODO: validate port value
//        throw fatalError("not yet implemented")
    }
    
}
