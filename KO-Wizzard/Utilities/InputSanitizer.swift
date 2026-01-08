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
		var cleaned = s.replacingOccurrences(of: ".", with: ",")
		cleaned = cleaned.filter { "0123456789,".contains($0) }

		let parts = cleaned.split(separator: ",")
		if parts.count > 2 {
			cleaned = parts.prefix(2).map(String.init).joined(separator: ",")
		}
		return cleaned
	}
}
