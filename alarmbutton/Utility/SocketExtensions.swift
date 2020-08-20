//
//  SocketExtensions.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 16/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation
import Socket

extension Socket {

    func read(into data: inout Data, size: Int) throws -> Int {
        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: size)
        defer { buffer.deallocate() }

        let bytesRead = try self.read(into: buffer, bufSize: size, truncate: true)
        data.append(UnsafeBufferPointer(start: buffer, count: bytesRead))

        return bytesRead
    }

}
