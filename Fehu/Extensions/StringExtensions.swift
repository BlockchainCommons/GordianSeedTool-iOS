//
//  StringExtensions.swift
//  Fehu
//
//  Created by Wolf McNally on 12/23/20.
//

import Foundation

extension String {
    func greek(conditional: Bool = true) -> String {
        guard conditional else { return self }
        let replacements = Array("⋯︙")
//        let replacements = Array("ᚢᛟᚨᚷᛗᛉᛇᛝᚾᛈᛏᚲᛃᚹᚠᚱᚺᛚᛖᛒᛊᛋᛁᛞᚦ")
        let c = Array(self).map { character in
            replacements[abs(character.hashValue) % replacements.count]
        }
        return String(c)
    }
    
    func trim() -> String { trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) }
}
