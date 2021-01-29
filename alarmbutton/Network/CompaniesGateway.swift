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

private let timeout: UInt = 10_000

protocol CompaniesGateway {
    func getCompanies(address: InetAddress) -> (RequestResult, [Company])
}

class CompaniesTcpGateway {

    private func makeRequest(address: InetAddress, query: String) -> (RequestResult, String?) {
        let coder = Coder()
        let data = coder.encode(text: query)

        guard let socket = try? Socket.create(family: .inet, type: .stream, proto: .tcp) else {
            return (.networkError, nil)
        }

        do {
            try socket.setWriteTimeout(value: timeout)
            try socket.setReadTimeout(value: timeout)

            try socket.connect(to: address.ip, port: address.port, timeout: timeout)
            defer { socket.close() }

            try socket.write(from: data)

            let bufferSize = 1024
            var responseData = Data()
            var bytesRead = 0

            bytesRead = try socket.read(into: &responseData, size: bufferSize)

            if bytesRead == 0 {
                return (.networkError, nil)
            }

            guard let messageSize = coder.decodeMessageSize(data: responseData) else {
                return (.parseError, nil)
            }

            while bytesRead < messageSize + 21 {
                let newBytesRead = try socket.read(into: &responseData, size: bufferSize)

                if newBytesRead == 0 {
                    return (.networkError, nil)
                }

                bytesRead += newBytesRead
            }

            guard let response = coder.decode(data: responseData) else {
                return (.parseError, nil)
            }

            return (.success, response)
        } catch let error {
            print(error.localizedDescription)
            return (.networkError, nil)
        }
    }

}

extension CompaniesTcpGateway: CompaniesGateway {

    func getCompanies(address: InetAddress) -> (RequestResult, [Company]) {
        let query = "{\"$c$\": \"getcity\"}"

        let (result, response) = makeRequest(address: address, query: query)

        guard result == .success else {
            return (result, [])
        }

        guard let data = response else {
            return (.error, [])
        }

        guard let companiesDTO = try? CompaniesDTO.parse(json: data) else {
            return (.parseError, [])
        }

        let companies = companiesDTO.data.flatMap { city in
            city.companies.map { companyDTO in
                Company(city: city.name, name: companyDTO.name, ipAddresses: companyDTO.ipAddresses)
            }
        }

        return (.success, companies)
    }

}
