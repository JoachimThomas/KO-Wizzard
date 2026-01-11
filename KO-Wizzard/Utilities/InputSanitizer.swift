//
//  InputSanitizer.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 26.11.25.


import Foundation

enum InputSanitizer {

		/// Zahleneingaben vereinheitlichen:
		/// - Punkt → Komma
		/// - erlaubt nur 0–9 und Komma
		/// - maximal ein Komma
	static func numeric(_ s: String) -> String {
		let replaced = s.replacingOccurrences(of: ".", with: ",")
		let allowed = Set("0123456789,")
		let filtered = replaced.filter { allowed.contains($0) }

		var result = ""
		var commaSeen = false

		for ch in filtered {
			if ch == "," {
				if commaSeen { continue }
				if result.isEmpty { continue }
				commaSeen = true
			}
			result.append(ch)
		}
		return result
	}
}
