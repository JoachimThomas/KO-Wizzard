//
//  ENUM_Constants.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 19.11.25.
//
import Foundation

	// MARK: - Normalisierung & Alias-Helfer

fileprivate func normalizedKey(_ s: String) -> String {
	let lower = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
	let folded = lower.folding(options: .diacriticInsensitive, locale: .current)
	return folded.replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
}

	// MARK: - AssetClass

enum AssetClass: String, CaseIterable, Identifiable, Codable {

	case index     = "index"
	case fx        = "fx"
	case aktie     = "aktie"
	case rohstoff  = "rohstoff"
	case crypto    = "crypto"
	case igBarrier = "igbarrier"
	case none      = ""


	var id: String { rawValue }

	var displayName: String {
		switch self {
			case .index:     return "Index"
			case .fx:        return "FX"
			case .aktie:     return "Aktie"
			case .rohstoff:  return "Rohstoff"
			case .crypto:    return "Crypto"
			case .igBarrier: return "IG-Barrier"
			case .none:      return ""

		}
	}



		/// Vorschläge für Subgroup-Auswahl (Dropdown etc.) – liefert weiterhin Strings,
		/// basiert intern aber auf dem typisierten Subgroup-Enum.
	static func subgroups(for asset: AssetClass) -> [String] {
		subgroupsTyped(for: asset).map { $0.displayName }
	}




		// tolerantes Decoding
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
		print("⚠️ Unbekannte AssetClass '\(raw)'. Fallback → index")
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
		"igbarriere": .igBarrier,
		
	]
}
extension AssetClass {

		/// Typisierte Subgroups für Picker & Logik
	static func subgroupsTyped(for asset: AssetClass) -> [Subgroup] {
		switch asset {
			case .index:
				return [.dax, .dow, .sp500, .nasdaq, .russell2000]
			case .fx:
				return [.eurUsd, .usdJpy, .gbpUsd]
			case .aktie:
				return []
			case .rohstoff:
				return [.oil, .gas, .gold]
			case .crypto:
				return [.bitcoinUsd, .ethereumUsd]
			case .igBarrier:
					// IG kann Index + FX + Rohstoff
				return [.dax, .dow, .sp500, .nasdaq, .eurUsd, .gold]
			case .none:
				return []
		}
	}
}

	// MARK: - Subgroup (Underlying-Typen für AssetClass)

enum Subgroup: String, CaseIterable, Identifiable,Codable {
	case dax
	case dow
	case sp500
	case nasdaq
	case russell2000

	case eurUsd
	case usdJpy
	case gbpUsd

	case oil
	case gas
	case gold

	case bitcoinUsd
	case ethereumUsd

	var id: String { rawValue }
}

extension Subgroup {

		/// Anzeigename für UI (Picker, Sidebar etc.)
	var displayName: String {
		switch self {
			case .dax:          return "DAX"
			case .dow:          return "Dow"
			case .sp500:        return "S&P 500"
			case .nasdaq:       return "Nasdaq"
			case .russell2000:  return "Russell 2000"

			case .eurUsd:       return "EUR/USD"
			case .usdJpy:       return "USD/JPY"
			case .gbpUsd:       return "GBP/USD"

			case .oil:          return "Öl"
			case .gas:          return "Gas"
			case .gold:         return "Gold"

			case .bitcoinUsd:   return "Bitcoin/USD"
			case .ethereumUsd:  return "Ethereum/USD"
		}
	}

		/// Zu welcher Asset-Klasse diese Subgroup logisch gehört
	var assetClass: AssetClass {
		switch self {
			case .dax, .dow, .sp500, .nasdaq, .russell2000:
				return .index
			case .eurUsd, .usdJpy, .gbpUsd:
				return .fx
			case .oil, .gas, .gold:
				return .rohstoff
			case .bitcoinUsd, .ethereumUsd:
				return .crypto
		}
	}
}

extension Subgroup {

	static func from(displayName: String) -> Subgroup? {
		let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return nil }

		return Self.allCases.first {
			$0.displayName.compare(trimmed,
								   options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
		}
	}
}

	// MARK: - Direction

enum Direction: String, CaseIterable, Identifiable, Codable {
	case long  = "long"
	case short = "short"
	case none = ""


	var id: String { rawValue }

	var displayName: String {
		switch self {
			case .long:  return "Long"
			case .short: return "Short"
			case .none:  return ""

		}
	}

	init(from decoder: Decoder) throws {
		let c = try decoder.singleValueContainer()
		let raw = try c.decode(String.self)
		switch normalizedKey(raw) {
			case "long":  self = .long
			case "short": self = .short
			case "none":  self = .none
			default:
#if DEBUG
				print("⚠️ Unbekannte Direction '\(raw)'. Fallback → long")
#endif
				self = .none
		}
	}

	func encode(to encoder: Encoder) throws {
		var c = encoder.singleValueContainer()
		try c.encode(self.rawValue)
	}
}

	// MARK: - Emittent

enum Emittent: String, CaseIterable, Identifiable, Codable {
	case bnp
	case citi
	case dzbank
	case goldman
	case hsbc
	case ing
	case jpmorgan
	case societegenerale
	case ubs
	case vontobel
	case igMarkets
	case none

	var id: String { rawValue }

	var displayName: String {
		switch self {
			case .bnp:             return "BNP Paribas"
			case .citi:            return "Citi"
			case .dzbank:          return "DZ Bank"
			case .goldman:         return "Goldman Sachs"
			case .hsbc:            return "HSBC"
			case .ing:             return "ING Markets"
			case .jpmorgan:        return "JP Morgan"
			case .societegenerale: return "Société Générale"
			case .ubs:             return "UBS"
			case .vontobel:        return "Vontobel"
			case .igMarkets:       return "IG-Markets"
			case .none:            return ""

		}
	}

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
		print("⚠️ Unbekannter Emittent '\(raw)'. Fallback → hsbc")
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

	// MARK: - Broker

enum Broker: String, CaseIterable, Identifiable, Codable {
	case tradeRepublic
	case finanzenNetZero
	case igMarkets
	case other
	

	var id: String { rawValue }

	var displayName: String {
		switch self {
			case .tradeRepublic:  return "TradeRepublic"
			case .finanzenNetZero:return "Finanzen.net Zero"
			case .igMarkets:      return "IG Markets"
			case .other:          return "Sonstiger Broker"

		}
	}

	init(from decoder: Decoder) throws {
		let c = try decoder.singleValueContainer()
		let raw = try c.decode(String.self)
		let key = normalizedKey(raw)

		switch key {
			case "traderepublic", "tr":
				self = .tradeRepublic
			case "finanzennetzero", "finanzennet", "fnz", "zero":
				self = .finanzenNetZero
			case "ig", "igmarkets", "ig-markets":
				self = .igMarkets
			default:
				self = .other
		}
	}

	func encode(to encoder: Encoder) throws {
		var c = encoder.singleValueContainer()
		try c.encode(self.rawValue)
	}
}
	// MARK: - Bezugsverhältnis (Ratio)

enum RatioOption: String, CaseIterable, Identifiable, Codable {
	case none = "–"
	case oneToOne    = "1 : 1"
	case oneToTen    = "1 : 10"
	case oneToHundred = "1 : 100"
	case oneToThousand = "1 : 1 000"
	case custom      = "Individuell…"

	var id: String { rawValue }

	var displayName: String { rawValue }

		// Reine Zahlenwerte für Speicherung, wenn nötig
	var numericValue: String {
		switch self {
			case .none:          return ""
			case .oneToOne:      return "1"
			case .oneToTen:      return "10"
			case .oneToHundred:  return "100"
			case .oneToThousand: return "1000"
			case .custom:        return "custom"
		}
	}
}

