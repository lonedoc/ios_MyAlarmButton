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
        token = appDataRepository.getToken()
        socket = RubegSocket()
        socket?.delegate = self
        try socket?.open()

        isStarted = true
    }

    func stop() {
        socket?.close()
        isStarted = false
    }

    func send(request: Request, to address: InetAddress, completion: @escaping (Bool) -> Void) {
        #if DEBUG
            print("Reqest: \(request.toString())")
        #endif

        socket?.send(
            message: request.toString(),
            token: request.type == .registration ? nil : token,
            to: address,
            complete: completion
        )
    }

}

extension NetworkServiceImpl: RubegSocketDelegate {

    func stringMessageReceived(_ message: String) {
        #if DEBUG
            print("Text message received: \(message)")
        #endif

        let data = Data(message.utf8)

        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return
        }

        guard let command = jsonObject["$c$"] as? String else { return }

        if command == "regok" {
            guard let tid = jsonObject["tid"] as? String else { return }

            let localRaw = jsonObject["local"] as? Int ?? 0
            let local = localRaw == 1

            if let phone = jsonObject["phone"] as? String {
                appDataRepository.set(securityPhone: phone)
            }

            token = tid
            appDataRepository.set(token: tid)
            appDataRepository.set(isLocal: local)

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

            NotificationCenter.default.post(name: .didReceiveCancelAlarmRequestResult, object: result)
        } else if command == "mobalarm" {
            guard let resultText = jsonObject["result"] as? String else { return }

            if resultText == "tokennotreg" {
                NotificationCenter.default.post(name: .didReceiveInvalidTokenMessage, object: nil)
            } else if resultText == "ok" {
                NotificationCenter.default.post(name: .didReceiveLocationResponse, object: nil)
            }
        }
    }

    func binaryMessageReceived(_ message: [Byte]) {}

}
