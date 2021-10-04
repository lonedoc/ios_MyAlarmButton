//
//  NetworkService.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 24/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation
import RubegProtocol_v2_0

protocol NetworkService {
    var isStarted: Bool { get }
    func start() throws
    func stop()
    func send(request: Request, to address: InetAddress, completion: @escaping (Bool) -> Void)
}

class NetworkServiceImpl: NetworkService {
    private static var shared: NetworkServiceImpl?

    public static func createSharedInstance(cacheManager: AppDataRepository) -> NetworkServiceImpl {
        if let shared = shared { return shared }

        shared = NetworkServiceImpl(cacheManager: cacheManager)
        return shared!
    }

    private let appDataRepository: AppDataRepository
    private var socket: RubegSocket?
    private var token: String?

    @Atomic private(set) var isStarted: Bool = false

    private init(cacheManager: AppDataRepository) {
        self.appDataRepository = cacheManager
    }

    func start() throws {
        #if DEBUG
            print("Network service started")
        #endif

        token = appDataRepository.getToken()
        socket = RubegSocket()
        socket?.delegate = self
        try socket?.open()

        isStarted = true
    }

    func stop() {
        #if DEBUG
            print("Network service stopped")
        #endif

        socket?.close()
        isStarted = false
    }

    func send(request: Request, to address: InetAddress, completion: @escaping (Bool) -> Void) {
        #if DEBUG
            print("Reqest [\(address.ip)]: \(request.toString())")
        #endif

        socket?.send(
            message: request.toString(),
            token: request.type == .registration ? nil : token,
            to: address,
            complete: completion
        )
    }

    private func replace(_ str: String?, symbol: Character, index: Int) -> String? {
        guard let str = str else { return nil }
        var arr = Array(str)
        arr[index] = symbol
        return String(arr)
    }
}

// MARK: RubegSocketDelegate

extension NetworkServiceImpl: RubegSocketDelegate {
    // swiftlint:disable:next cyclomatic_complexity
    func stringMessageReceived(_ message: String) {
        #if DEBUG
            print("Text message received: \(message)")
        #endif

        let data = Data(message.utf8)

        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return
        }

        guard let command = jsonObject["$c$"] as? String else { return }

        if command == "checkconnection" {
            let blocked = jsonObject["block"] as? Int == 1
            let description = jsonObject["desc"] as? String

            if blocked {
                NotificationCenter.default.post(name: .didReceiveAccountBlockedMessage, object: nil, userInfo: ["description": description])
            }

            let patrolModeTimeout = jsonObject["alarmback"] as? Int ?? 0
            NotificationCenter.default.post(name: .didReceivePatrolModeTimeoutValue, object: nil, userInfo: ["timeout": patrolModeTimeout])
        } else if command == "regok" {
            guard let tid = jsonObject["tid"] as? String else { return }

            print("TID: \(tid)")

            let patrolMode = jsonObject["patrol"] as? Int ?? 0 != 0
            let local = jsonObject["local"] as? Int == 1

            if let phone = jsonObject["phone"] as? String {
                appDataRepository.set(securityPhone: phone)
            }

            token = tid
            appDataRepository.set(token: tid)
            appDataRepository.set(isLocal: local)
            appDataRepository.set(patrolMode: patrolMode)

            NotificationCenter.default.post(name: .didReceiveRegistrationResult, object: nil)
        } else if command == "getpassword" {
            guard let result = jsonObject["result"] as? String else { return }

            let success = result == "ok"

            NotificationCenter.default.post(name: .didReceivePasswordRequestResult, object: success)
        } else if command == "cancelalarm" {
            guard let resultText = jsonObject["result"] as? String else { return }

            let result: CancelAlarmRequestResult

            switch resultText {
            case "ok":
                result = .ok
            case "codeerror":
                result = .wrongCode
            default:
                result = .unknown
            }

            NotificationCenter.default.post(name: .didReceiveCancelAlarmRequestResult, object: nil, userInfo: ["result": result])
        } else if command == "mobalarm" {
            guard let resultText = jsonObject["result"] as? String else { return }

            if resultText == "tokennotreg" {
                NotificationCenter.default.post(name: .didReceiveInvalidTokenMessage, object: nil)
            } else if resultText == "ok" {
                NotificationCenter.default.post(name: .didReceiveLocationResponse, object: nil)
            }
        } else if command == "logo" {
            if
                let result = jsonObject["result"] as? String,
                result == "notrefresh"
            {
                return
            }

            guard let base64string = jsonObject["data"] as? String else { return }

            guard let data = Data(base64Encoded: base64string) else {
                print("Couldn't decode base64 string")
                return
            }

            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = URL(fileURLWithPath: "company_logo", relativeTo: directoryURL).appendingPathExtension("jpg")

            do {
                try data.write(to: fileURL)
                NotificationCenter.default.post(name: .didFetchCompanyLogo, object: nil)
            } catch let error {
                print(error.localizedDescription)
                return
            }
        }
    }

    func binaryMessageReceived(_ message: [Byte]) {}
}
