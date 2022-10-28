//
//  CompaniesGateway.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 16/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import RubegProtocol_v2_0
import Foundation
import Socket
import RxSwift

private let host: String = "lk.rubeg38.ru"
private let port: Int32 = 8300

private typealias Response = (
    command: String,
    message: String
)

protocol GuardServicesGateway {
    func getGuardServices() -> Observable<[GuardService]>
}

class GuardServicesGatewayImpl: RubegSocketDelegate, GuardServicesGateway {

    private var guardServicesSubject: PublishSubject<[GuardService]>?

    lazy var socket: RubegSocket = {
        let socket = RubegSocket()
        socket.delegate = self
        return socket
    }()

    func getGuardServices() -> Observable<[GuardService]> {
        let isSocketReady = prepareSocket()

        if !isSocketReady {
            return Observable.error(NetworkError.socketError)
        }

        let addresses = InetAddress.createAll(hosts: [host], port: port)

        if addresses.isEmpty {
            return Observable.error(NetworkError.addressError)
        }

        let subject = guardServicesSubject ?? PublishSubject<[GuardService]>()
        guardServicesSubject = subject

        let query = "{\"$c$\": \"getcity\"}"

        makeRequest(query: query, addresses: addresses, subject: subject, 5)

        return subject
    }

    func stringMessageReceived(_ message: String) {
        #if DEBUG
            print("<- \(message)")
        #endif

        guard let response = parseResponse(source: message) else {
            return
        }

        switch response.command {
        case "city":
            guard let guardServicesDto = try? GuardServicesDto.parse(json: response.message) else {
                let subject = guardServicesSubject
                guardServicesSubject = nil
                subject?.onError(NetworkError.parseError)
                return
            }

            let guardServices = guardServicesDto.data.flatMap { city in
                city.guardServices.map { guardServiceDto in
                    GuardService(city: city.name, name: guardServiceDto.name, hosts: guardServiceDto.hosts)
                }
            }

            guardServicesSubject?.onNext(guardServices)
            guardServicesSubject = nil
            socket.close()
        default:
            return
        }
    }

    func binaryMessageReceived(_ message: [Byte]) { }

    private func prepareSocket() -> Bool {
        if !socket.opened {
            do {
                try socket.open()
                return true
            } catch let error {
                #if DEBUG
                    print(error.localizedDescription)
                #endif

                return false
            }
        }

        return true
    }

    private func makeRequest(
        query: String,
        addresses: [InetAddress],
        subject: PublishSubject<[GuardService]>,
        _ attempts: Int = 3
    ) {
        if attempts < 1 {
            subject.onError(NetworkError.serverError)
            return
        }

        let address = addresses[attempts % addresses.count]

        #if DEBUG
            print("[\(address.ip)] -> \(query)")
        #endif

        socket.send(message: query, token: nil, to: address) { [weak self] success in
            if !success {
                self?.makeRequest(
                    query: query,
                    addresses: addresses,
                    subject: subject,
                    attempts - 1
                )
            }
        }
    }

    private func parseResponse(source: String) -> Response? {
        guard
            let sourceData = source.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: sourceData, options: []),
            let jsonMap = jsonObject as? [String: Any],
            let command = jsonMap["$c$"] as? String
        else {
            return nil
        }

        guard
            let jsonData = jsonMap["data"],
            let data = try? JSONSerialization.data(withJSONObject: jsonData, options: []),
            let dataStr = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        return (command, dataStr)
    }

}
