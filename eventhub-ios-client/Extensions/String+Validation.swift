//
//  String+Validation.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 11.07.2026.
//

import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isBlank: Bool {
        trimmed.isEmpty
    }

    var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailFormat).evaluate(with: trimmed)
    }

    var isValidShortId: Bool {
        range(of: "^[a-zA-Z0-9]+$", options: .regularExpression) != nil
    }
}
