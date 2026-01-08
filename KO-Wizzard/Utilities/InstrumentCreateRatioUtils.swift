//
//  InstrumentCreateRatioUtils.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 26.11.25.


import Foundation

func customRatioInitialValue(from raw: String) -> String {
	let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
	if trimmed.isEmpty { return "" }

	let compact = trimmed.replacingOccurrences(of: " ", with: "")
	if compact.contains(":") {
		let parts = compact.split(separator: ":")
		if parts.count == 2 {
			return String(parts[1])
		}
	}
	return trimmed
}

func ratioOptionForValue(_ raw: String) -> RatioOption {
	let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
	if trimmed.isEmpty { return .none }

	if let direct = RatioOption.allCases.first(where: { $0.numericValue == trimmed }) {
		return direct
	}

	let compact = trimmed.replacingOccurrences(of: " ", with: "")
	if compact.contains(":") {
		let parts = compact.split(separator: ":")
		if parts.count == 2 {
			let right = String(parts[1])
			if let match = RatioOption.allCases.first(where: { $0.numericValue == right }) {
				return match
			} else {
				return .custom
			}
		}
	}

	if let _ = Double(compact) {
		if let match = RatioOption.allCases.first(where: { $0.numericValue == compact }) {
			return match
		}
		return .custom
	}

	return .none
}
