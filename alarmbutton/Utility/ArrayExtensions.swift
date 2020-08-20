//
//  ArrayExtensions.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 18/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

extension Array {

    func distinct(comparator: (Element, Element) -> Bool) -> [Element] {
        var distinctValues = [Element]()

        self.forEach { item in
            if !(distinctValues.contains { comparator($0, item) }) {
                distinctValues.append(item)
            }
        }

        return distinctValues
    }

}
