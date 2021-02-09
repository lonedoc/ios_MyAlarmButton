//
//  CacheManager.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 02/07/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

protocol AppDataRepository {
    var hasCompany: Bool { get }
    var hasCountryCode: Bool { get }
    var hasPhone: Bool { get }
    var hasToken: Bool { get }
    var hasPassword: Bool { get }
    var hasIsLocal: Bool { get }
    var hasPatrolMode: Bool { get }
    var hasSecurityPhone: Bool { get }
//    var hasIsBlocked: Bool { get }
    func set(company: Company)
    func set(countryCode: String)
    func set(phone: String)
    func set(token: String)
    func set(password: String)
    func set(isLocal: Bool)
    func set(patrolMode: Bool)
    func set(securityPhone: String)
//    func set(isBlocked: Bool)
    func getCompany() -> Company?
    func getCountryCode() -> String?
    func getPhone() -> String?
    func getToken() -> String?
    func getPassword() -> String?
    func getIsLocal() -> Bool?
    func getPatrolMode() -> Bool?
    func getSecurityPhone() -> String?
//    func getIsBlocked() -> Bool?
    func clearCache()
}

class UserDefaultsAppDataRepository: AppDataRepository {
    private let keys = (
        city: "city",
        company: "company",
        ip: "ip",
        countryCode: "countryCode",
        phone: "phone",
        token: "token",
        password: "password",
        isLocal: "isLocal",
        patrolMode: "patrolMode",
        securityPhone: "securityPhone"//,
//        isBlocked: "isBlocked"
    )

    var hasCompany: Bool {
        return
            UserDefaults.standard.string(forKey: keys.city) != nil &&
            UserDefaults.standard.string(forKey: keys.company) != nil &&
            UserDefaults.standard.stringArray(forKey: keys.ip) != nil
    }

    var hasCountryCode: Bool {
        return UserDefaults.standard.string(forKey: keys.countryCode) != nil
    }

    var hasPhone: Bool {
        return UserDefaults.standard.string(forKey: keys.phone) != nil
    }

    var hasToken: Bool {
        return UserDefaults.standard.string(forKey: keys.token) != nil
    }

    var hasPassword: Bool {
        return UserDefaults.standard.string(forKey: keys.password) != nil
    }

    var hasIsLocal: Bool {
        return UserDefaults.standard.object(forKey: keys.isLocal) != nil
    }

    var hasPatrolMode: Bool {
        return UserDefaults.standard.object(forKey: keys.patrolMode) != nil
    }

    var hasSecurityPhone: Bool {
        return UserDefaults.standard.string(forKey: keys.securityPhone) != nil
    }

//    var hasIsBlocked: Bool {
//        return UserDefaults.standard.object(forKey: keys.isBlocked) != nil
//    }

    func set(company: Company) {
        UserDefaults.standard.set(company.city, forKey: keys.city)
        UserDefaults.standard.set(company.name, forKey: keys.company)
        UserDefaults.standard.set(company.ipAddresses, forKey: keys.ip)
    }

    func set(countryCode: String) {
        UserDefaults.standard.set(countryCode, forKey: keys.countryCode)
    }

    func set(phone: String) {
        UserDefaults.standard.set(phone, forKey: keys.phone)
    }

    func set(token: String) {
        UserDefaults.standard.set(token, forKey: keys.token)
    }

    func set(password: String) {
        UserDefaults.standard.set(password, forKey: keys.password)
    }

    func set(isLocal: Bool) {
        UserDefaults.standard.set(isLocal, forKey: keys.isLocal)
    }

    func set(patrolMode: Bool) {
        UserDefaults.standard.set(patrolMode, forKey: keys.patrolMode)
    }

    func set(securityPhone: String) {
        UserDefaults.standard.set(securityPhone, forKey: keys.securityPhone)
    }

//    func set(isBlocked: Bool) {
//        UserDefaults.standard.set(isBlocked, forKey: keys.isBlocked)
//    }

    func getCompany() -> Company? {
        guard
            let city = UserDefaults.standard.string(forKey: keys.city),
            let company = UserDefaults.standard.string(forKey: keys.company),
            let ipAddresses = UserDefaults.standard.stringArray(forKey: keys.ip)
        else {
            return nil
        }

        return Company(city: city, name: company, ipAddresses: ipAddresses)
    }

    func getCountryCode() -> String? {
        return UserDefaults.standard.string(forKey: keys.countryCode)
    }

    func getPhone() -> String? {
        return UserDefaults.standard.string(forKey: keys.phone)
    }

    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: keys.token)
    }

    func getPassword() -> String? {
        return UserDefaults.standard.string(forKey: keys.password)
    }

    func getIsLocal() -> Bool? {
        if !hasIsLocal {
            return nil
        }

        return UserDefaults.standard.bool(forKey: keys.isLocal)
    }

    func getPatrolMode() -> Bool? {
        if !hasPatrolMode {
            return nil
        }

        return UserDefaults.standard.bool(forKey: keys.patrolMode)
    }

    func getSecurityPhone() -> String? {
        return UserDefaults.standard.string(forKey: keys.securityPhone)
    }

//    func getIsBlocked() -> Bool? {
//        if !hasIsBlocked {
//            return nil
//        }
//
//        return UserDefaults.standard.bool(forKey: keys.isBlocked)
//    }

    func clearCache() {
        let userDefaults = UserDefaults.standard

        userDefaults.removeObject(forKey: keys.city)
        userDefaults.removeObject(forKey: keys.company)
        userDefaults.removeObject(forKey: keys.ip)
        userDefaults.removeObject(forKey: keys.countryCode)
        userDefaults.removeObject(forKey: keys.phone)
        userDefaults.removeObject(forKey: keys.token)
        userDefaults.removeObject(forKey: keys.password)
    }

}
