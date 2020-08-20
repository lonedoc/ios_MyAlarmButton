//
//  PhoneMask.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 21/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation

class PhoneMask {

    // swiftlint:disable opening_brace
    private var rules: [(Character) -> Bool] {
        return [
            { $0 == "(" },
            { self.isDigit(char: $0) },
            { self.isDigit(char: $0) },
            { self.isDigit(char: $0) },
            { $0 == ")" },
            { $0 == " " },
            { self.isDigit(char: $0) },
            { self.isDigit(char: $0) },
            { self.isDigit(char: $0) },
            { $0 == "-" },
            { self.isDigit(char: $0) },
            { self.isDigit(char: $0) },
            { $0 == "-" },
            { self.isDigit(char: $0) },
            { self.isDigit(char: $0) }
        ]
    }
    // swiftlint:enable opening_brace

    func validate(_ value: String) -> Bool {
        guard value.count == 15 else {
            return false
        }

        let characters = Array(value)

        guard
            characters[0] == "(",
            characters[4] == ")",
            characters[5] == " ",
            characters[9] == "-",
            characters[12] == "-"
        else {
            return false
        }

        let digitIndexes = [1, 2, 3, 6, 7, 8, 10, 11, 13, 14]
        if (digitIndexes.contains { !isDigit(char: characters[$0]) }) {
            return false
        }

        return true
    }

    func validatePart(_ value: String) -> Bool {
        guard value.count <= rules.count else {
            return false
        }

        let characters = Array(value)

        var index = 0
        while index < rules.count && index < characters.count {
            let rule = rules[index]
            let char = characters[index]

            guard rule(char) else {
                return false
            }

            index += 1
        }

        return true
    }

    func apply(to value: String) -> String {
        let digits = extractDigits(from: value)
        var index = 0

        var result = "("

        guard insert(count: 3, into: &result, from: digits, start: &index) else {
            return result
        }

        result.append(") ")

        guard insert(count: 3, into: &result, from: digits, start: &index) else {
            return result
        }

        result.append("-")

        guard insert(count: 2, into: &result, from: digits, start: &index) else {
            return result
        }

        result.append("-")

        _ = insert(count: 2, into: &result, from: digits, start: &index)

        return result
    }

    private func insert(
        count: Int,
        into string: inout String,
        from characters: [Character],
        start index: inout Int
    ) -> Bool {
        for _ in 0 ..< count {
            guard index < characters.count else {
                return false
            }

            string.append(characters[index])
            index += 1
        }

        return true
    }

    private func extractDigits(from string: String) -> [Character] {
        return string.filter { isDigit(char: $0) }
    }

    private func isDigit(char: Character) -> Bool {
        return "0123456789".contains(char)
    }

}
