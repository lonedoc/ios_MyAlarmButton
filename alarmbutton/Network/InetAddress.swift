//
//  InetAddress.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 17/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

//class InetAddress {
//
//    let address: String
//    let port: Int32
//
//    static func create(address addressValue: String, port portValue: Int32) throws -> InetAddress {
//        try validate(address: addressValue)
//        try validate(port: portValue)
//
//        return InetAddress(address: addressValue, port: portValue)
//    }
//
//    private init(address addressValue: String, port portValue: Int32) {
//        address = addressValue
//        port = portValue
//    }
//
//    private static func validate(address: String) throws {
//        let regex = "((1\\d{1,2}|25[0-5]|2[0-4]\\d|\\d{1,2})\\.){3}(1\\d{1,2}|25[0-5]|2[0-4]\\d|\\d{1,2})"
//        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
//
//        if !predicate.evaluate(with: address) {
//            throw fatalError("Invalid IPv4 address")
//        }
//    }
//
//    private static func validate(port: Int32) throws {
//        if port < 0 || port > 65535 {
//            throw fatalError("Invalid port")
//        }
//    }
//
//}
