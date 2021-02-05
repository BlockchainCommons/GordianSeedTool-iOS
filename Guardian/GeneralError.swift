//
//  GeneralError.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/21/20.
//

import Foundation

struct GeneralError: LocalizedError {
    let errorDescription: String?

    init(_ errorDescription: String) {
        self.errorDescription = errorDescription
    }
}
