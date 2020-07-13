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

class NetworkServiceImpl : NetworkService {
    
    public static let shared: NetworkServiceImpl = {
        return NetworkServiceImpl()
    }()

    private var socket: RubegSocket? = nil
    private var token: String? = nil
    
    private(set) var isStarted: Bool = false // TODO: Make it thread-safe
    
    func start() throws {
        // TODO: Move it out here
        token = UserDefaultsCacheManager().getToken()
        
        socket = try RubegSocket()
        socket?.delegate = self
        socket?.open()
        
        isStarted = true
    }
    
    func stop() {
        socket?.close()
        isStarted = false
    }
    
    func send(request: Request, to address: InetAddress, completion: @escaping (Bool) -> Void) {
        print("Send to \(address.address):\(address.port)")
        print(request.toString())
        
        let host = Host(address.address, address.port)
        socket?.send(message: request.toString(), token: token, to: host, completion: completion)
    }
    
}

extension NetworkServiceImpl : RubegSocketDelegate {
    
    func stringMessageReceived(_ message: String) {
        // TODO: Extract the parsing logic to separate object
        print("Text message received: \(message)")
        
        let data = Data(message.utf8)
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return
        }
        
        guard let command = jsonObject["$c$"] as? String else {
            return
        }
        
        if command == "regok" {
            guard let tid = jsonObject["tid"] as? String else {
                return
            }
            
            token = tid
            
            // TODO: Move it out here
            UserDefaults.standard.set(token, forKey: "token")
            
            NotificationCenter.default.post(name: .didReceiveRegistrationResult, object: nil)
        } else if command == "getpassword" {
            guard let result = jsonObject["result"] as? String else {
                return
            }
            
            let success = result == "ok"
            
            NotificationCenter.default.post(name: .didReceivePasswordRequestResult, object: success)
        } else if command == "cancelalarm" {
            guard let resultText = jsonObject["result"] as? String else {
                return
            }
            
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
        }
    }
    
    func binaryMessageReceived(_ message: [Byte]) {
        // TODO: Implement this
    }
    
}

// {"$c$":"regok","tid":"D68CB802-46B2-417C-A103-7A6146264781"}
// {"$c$":"getpassword","result":"ok"}
// {"$c$":"mobalarm","result":"ok","code":6397}
// {"$c$":"cancelalarm","result":"codeerror"}
// {"$c$":"cancelalarm","result":"ok"}
