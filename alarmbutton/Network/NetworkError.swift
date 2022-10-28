//
//  NetworkError.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 20.10.2022.
//  Copyright © 2022 Rubeg NPO. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case socketError
    case addressError
    case serverError
    case parseError
}

extension NetworkError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .socketError:
            return "socket_error".localized
        case .addressError:
            return "address_error".localized
        case .serverError:
            return "server_error".localized
        case .parseError:
            return "parse_error".localized
        }
    }

}
