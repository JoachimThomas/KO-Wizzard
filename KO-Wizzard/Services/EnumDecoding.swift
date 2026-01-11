//
//  EnumDecoding.swift
//  KO-Wizzard
//

import Foundation

// MARK: - Helpers

fileprivate func normalizedKey(_ s: String) -> String {
	let lower = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
	let folded = lower.folding(options: .diacriticInsensitive, locale: .current)
	return folded.replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
}

// MARK: - AssetClass Codable

extension AssetClass {
	init(from decoder: Decoder) throws {
		let c = try decoder.singleValueContainer()
		let raw = try c.decode(String.self)
		let key = normalizedKey(raw)

		if let direct = AssetClass.allCases.first(where: { $0.rawValue == key }) {
			self = direct
			return
		}
		if let mapped = AssetClass.aliases[key] {
			self = mapped
			return
		}
		if let byDisplay = AssetClass.allCases.first(where: { normalizedKey($0.displayName) == key }) {
			self = byDisplay
			return
		}

#if DEBUG
		print("⚠️ Unbekannte AssetClass '\(raw)'. Fallback → none")
#endif
		self = .none
	}

	func encode(to encoder: Encoder) throws {
		var c = encoder.singleValueContainer()
		try c.encode(self.rawValue)
	}

	private static let aliases: [String: AssetClass] = [
		"indices": .index,
		"indizes": .index,
		"stocks": .aktie,
		"equity": .aktie,
		"aktien": .aktie,
		"commodities": .rohstoff,
		"rohstoffe": .rohstoff,
		"cryptos": .crypto,
		"krypto": .crypto,
		"ig": .igBarrier,
		"igbarriere": .igBarrier
	]
}

// MARK: - Direction Codable

extension Direction {
	init(from decoder: Decoder) throws {
		let c = try decoder.singleValueContainer()
		let raw = try c.decode(String.self)
		switch normalizedKey(raw) {
			case "long":  self = .long
			case "short": self = .short
			case "none":  self = .none
			default:
#if DEBUG
				print("⚠️ Unbekannte Direction '\(raw)'. Fallback → none")
#endif
				self = .none
		}
	}

	func encode(to encoder: Encoder) throws {
		var c = encoder.singleValueContainer()
		try c.encode(self.rawValue)
	}
}

// MARK: - Emittent Codable

extension Emittent {
	init(from decoder: Decoder) throws {
		let c = try decoder.singleValueContainer()
		let raw = try c.decode(String.self)
		let key = normalizedKey(raw)

		if let direct = Emittent.allCases.first(where: { $0.rawValue == key }) {
			self = direct
			return
		}
		if let mapped = Emittent.aliases[key] {
			self = mapped
			return
		}
		if let byDisplay = Emittent.allCases.first(where: { normalizedKey($0.displayName) == key }) {
			self = byDisplay
			return
		}

#if DEBUG
		print("⚠️ Unbekannter Emittent '\(raw)'. Fallback → none")
#endif
		self = .none
	}

	func encode(to encoder: Encoder) throws {
		var c = encoder.singleValueContainer()
		try c.encode(self.rawValue)
	}

	private static let aliases: [String: Emittent] = [
		"bnpparibas": .bnp,
		"bnp": .bnp,
		"citi": .citi,
		"citigroup": .citi,
		"citibank": .citi,
		"dz": .dzbank,
		"dzbank": .dzbank,
		"deutschezentralgenossenschaftsbank": .dzbank,
		"goldmansachs": .goldman,
		"gs": .goldman,
		"goldman": .goldman,
		"hsbc": .hsbc,
		"ing": .ing,
		"ingmarkets": .ing,
		"jpmorgan": .jpmorgan,
		"jpm": .jpmorgan,
		"societegenerale": .societegenerale,
		"societe": .societegenerale,
		"ubs": .ubs,
		"vontobel": .vontobel,
		"ig": .igMarkets,
		"igmarkets": .igMarkets,
		"ig-markets": .igMarkets
	]
}
