	//
	//  BasicsImportParser.swift
	//  KO-Wizzard
	//

import Foundation

	/// Ergebnis des Basisdaten-Imports.
	/// Nur Felder, die im Instrument benötigt werden.
struct ImportedInstrumentBasics {
	var assetClass: AssetClass?
	var subgroup: String?
	var direction: Direction?
	var emittent: Emittent?
	var isin: String?
	var basispreis: String?
	var ratioDisplay: String?
	var aufgeld: String?
}

	/// Parser für Freitext (z. B. HSBC-Seiten), der nur die Instrument-Basisdaten ermittelt.
enum BasicsImportParser {

	static func parse(raw: String) -> ImportedInstrumentBasics {

		let original = raw.replacingOccurrences(of: "\r\n", with: "\n")
		let lines = original.components(separatedBy: .newlines)

		var result = ImportedInstrumentBasics()

			// Rohwerte für spätere Mapping-Schritte
		var basiswertName: String?
		var rawIsin: String?

		for line in lines {
			let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
			if trimmed.isEmpty { continue }

			let norm = trimmed
				.folding(options: [.diacriticInsensitive, .caseInsensitive],
						 locale: Locale(identifier: "de_DE"))
				.lowercased()

				// ISIN-Zeile: "ISIN: DE000HT8J3S8"
			if norm.contains("isin") {
				if let isin = extractIsin(from: trimmed) {
					rawIsin = isin
				}
				continue
			}

				// Basiswert-Zeile: "Basiswert    Dow Jones Industrial Average®"
			if norm.hasPrefix("basiswert") {
				basiswertName = extractValueAfterLabel(from: trimmed, label: "Basiswert")
				continue
			}

				// Optionsscheintyp: "Optionsscheintyp    Put"
			if norm.contains("optionsscheintyp") {
				if let dir = extractDirection(from: trimmed) {
					result.direction = dir
				}
				continue
			}

				// Bezugsverhältnis: "Bezugsverhältnis    0,001"
			if norm.contains("bezugsverhaltnis") {
				result.ratioDisplay = extractRatio(from: trimmed)
				continue
			}

				// Basispreis: "Basispreis    47.380,7438 Pkt."
			if norm.hasPrefix("basispreis"), result.basispreis == nil {
				result.basispreis = extractNumberLike(from: trimmed)
				continue
			}

				// Aufgeld: "Aufgeld    0,04 EUR"
			if norm.contains("aufgeld") {
				result.aufgeld = extractNumberLike(from: trimmed)
				continue
			}
		}

			// ISIN + Emittent
		if let isin = rawIsin {
			result.isin = isin
			result.emittent = mapEmittent(fromIsin: isin)
		}

			// Subgroup aus Basiswert
		if let basiswertName {
			result.subgroup = mapSubgroup(fromBasiswert: basiswertName)
		} else {
				// Fallback: heuristisch im Gesamttest suchen
			let normalizedText = original
				.folding(options: [.diacriticInsensitive, .caseInsensitive],
						 locale: Locale(identifier: "de_DE"))
				.lowercased()
			result.subgroup = extractSubgroupHeuristic(from: normalizedText)
		}

			// AssetClass aus Subgroup
		result.assetClass = mapAssetClass(from: result.subgroup)

		return result
	}

		// MARK: - ISIN

		/// Liest aus einer Zeile wie "ISIN: DE000HT8J3S8" den Wert nach "ISIN:"
	private static func extractIsin(from line: String) -> String? {
			// grob: alles hinter "ISIN"
		guard let range = line.range(of: "ISIN", options: [.caseInsensitive, .diacriticInsensitive]) else {
			return nil
		}

		var tail = line[range.upperBound...]
			// optional ":" entfernen
		if let colon = tail.firstIndex(of: ":") {
			tail = tail[tail.index(after: colon)...]
		}

		let trimmed = tail.trimmingCharacters(in: .whitespacesAndNewlines)

			// ISIN = erstes "Wort" bis zum nächsten Whitespace
		var token = ""
		for ch in trimmed {
			if ch.isWhitespace { break }
			token.append(ch)
		}

		let isin = token.trimmingCharacters(in: CharacterSet(charactersIn: ".,;")).uppercased()

		guard isin.count == 12,
			  isin.prefix(2).allSatisfy({ $0.isLetter }) else {
			return nil
		}
		return isin
	}

		/// extrahiert die "WKN-Komponente" aus der ISIN (Stellen 3–8)
	private static func extractWknPart(fromIsin isin: String) -> String? {
			// Erwartet Schema "DE000" + WKN(6) + Checkdigit
		guard isin.count >= 12 else { return nil }

			// Start nach "DE000" → Index 5 (0-basiert)
		let start = isin.index(isin.startIndex, offsetBy: 5)
		let end   = isin.index(start, offsetBy: 6)
		return String(isin[start..<end])
	}
		// MARK: - Basiswert / allgemeiner Label-Parser

		/// Nimmt z. B. "Basiswert    Dow Jones Industrial Average®"
		/// und gibt "Dow Jones Industrial Average®" zurück.
	private static func extractValueAfterLabel(from line: String, label: String) -> String? {
		guard let range = line.range(of: label, options: [.caseInsensitive, .diacriticInsensitive]) else {
			return nil
		}
		var tail = line[range.upperBound...]
			// Tabs, Doppelpunkte, Bindestriche wegputzen
		while let first = tail.first, first == ":" || first == "-" || first == "\t" || first == " " {
			tail = tail.dropFirst()
		}
		let trimmed = tail.trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmed.isEmpty ? nil : trimmed
	}

		// MARK: - Richtung

		/// Liest aus einer Zeile wie "Optionsscheintyp    Put" die Richtung
	private static func extractDirection(from line: String) -> Direction? {
		let norm = line
			.folding(options: [.diacriticInsensitive, .caseInsensitive],
					 locale: Locale(identifier: "de_DE"))
			.lowercased()

		if norm.contains("call") { return .long }
		if norm.contains("put")  { return .short }
		return nil
	}

		// MARK: - Zahlen / Basispreis / Aufgeld

		/// Extrahiert die erste "Zahl" aus einer Zeile (inkl. Punkt/Komma), normalisiert auf deutsches Format.
	private static func extractNumberLike(from line: String) -> String? {
		let pattern = #"[0-9\.\,]+"#
		guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }

		let range = NSRange(line.startIndex..<line.endIndex, in: line)
		if let match = regex.firstMatch(in: line, options: [], range: range),
		   let r = Range(match.range(at: 0), in: line) {

			let raw = String(line[r]).trimmingCharacters(in: .whitespaces)

				// "47.380,7438" → "47380,7438"
			var cleaned = raw.replacingOccurrences(of: " ", with: "")
				// Tausenderpunkte entfernen
			if cleaned.contains(",") {
				cleaned = cleaned.replacingOccurrences(of: ".", with: "")
			}
			return cleaned
		}
		return nil
	}

		// MARK: - Bezugsverhältnis → "1 : X"

		/// Nimmt Zeile "Bezugsverhältnis    0,001" und gibt "1 : 1000" zurück.
	private static func extractRatio(from line: String) -> String? {
		guard let numString = extractNumberLike(from: line) else { return nil }

		let normalized = numString.replacingOccurrences(of: ",", with: ".")
		guard let val = Double(normalized), val > 0 else { return nil }

		let denom = Int(round(1.0 / val))
		return "1 : \(denom)"
	}

		// MARK: - Subgroup-Mapping

		/// Mappt den Basiswert-Namen auf die in der App verwendeten Subgroup-Namen.
	private static func mapSubgroup(fromBasiswert name: String) -> String? {
		let lower = name
			.folding(options: [.diacriticInsensitive, .caseInsensitive],
					 locale: Locale(identifier: "de_DE"))
			.lowercased()

			// INDEX
		if lower.contains("dow jones") {
			return "Dow"
		}
		if lower.contains("dax") {
			return "DAX"
		}
		if lower.contains("s&p") || lower.contains("sp ") || lower.contains("s and p") {
			return "S&P 500"
		}
		if lower.contains("nasdaq") {
			return "Nasdaq"
		}
		if lower.contains("russell") {
			return "Russell 2000"
		}

			// FX
		if lower.contains("eur/usd") {
			return "EUR/USD"
		}
		if lower.contains("usd/jpy") {
			return "USD/JPY"
		}
		if lower.contains("gbp/usd") {
			return "GBP/USD"
		}

			// ROHSTOFFE
		if lower.contains("gold") {
			return "Gold"
		}
		if lower.contains("öl") || lower.contains("oel") || lower.contains("oil") {
			return "Öl"
		}
		if lower.contains("gas") {
			return "Gas"
		}

			// CRYPTO (falls HSBC irgendwann dazu kommt…)
		if lower.contains("bitcoin") || lower.contains("btc") {
			return "Bitcoin/USD"
		}
		if lower.contains("ethereum") || lower.contains("eth") {
			return "Ethereum/USD"
		}

		return nil
	}

		/// Fallback, wenn kein Basiswert gefunden wurde – heuristisch über den Gesamttest.
	private static func extractSubgroupHeuristic(from normalized: String) -> String? {
		if normalized.contains("dow jones") { return "Dow" }
		if normalized.contains("dax") { return "DAX" }
		if normalized.contains("s&p 500") || normalized.contains("s&p500") { return "S&P 500" }
		if normalized.contains("nasdaq") { return "Nasdaq" }
		if normalized.contains("russell 2000") { return "Russell 2000" }

		if normalized.contains("eur/usd") { return "EUR/USD" }
		if normalized.contains("usd/jpy") { return "USD/JPY" }
		if normalized.contains("gbp/usd") { return "GBP/USD" }

		if normalized.contains("gold") { return "Gold" }
		if normalized.contains("öl") || normalized.contains("oel") || normalized.contains("oil") { return "Öl" }
		if normalized.contains("gas") { return "Gas" }

		if normalized.contains("bitcoin") || normalized.contains("btc") { return "Bitcoin/USD" }
		if normalized.contains("ethereum") || normalized.contains("eth") { return "Ethereum/USD" }

		return nil
	}

		// MARK: - AssetClass aus Subgroup

	private static func mapAssetClass(from subgroup: String?) -> AssetClass? {
		guard let s = subgroup?.lowercased() else { return nil }

		if s.contains("dax")
			|| s.contains("dow")
			|| s.contains("s&p")
			|| s.contains("nasdaq")
			|| s.contains("russell") {
			return .index
		}

		if s.contains("eur/usd")
			|| s.contains("usd/jpy")
			|| s.contains("gbp/usd") {
			return .fx
		}

		if s.contains("gold")
			|| s.contains("öl")
			|| s.contains("oel")
			|| s.contains("gas") {
			return .rohstoff
		}

		if s.contains("bitcoin")
			|| s.contains("ethereum")
			|| s.contains("btc")
			|| s.contains("eth") {
			return .crypto
		}

		return nil
	}

		// MARK: - Emittent aus ISIN (via WKN-Anteil)

	private static func mapEmittent(fromIsin isin: String?) -> Emittent? {
		guard let isin,
			  let w = extractWknPart(fromIsin: isin)?.uppercased() else { return nil }

			// BNP Paribas
		if w.hasPrefix("PF") || w.hasPrefix("PP") || w.hasPrefix("PR") || w.hasPrefix("PA") || w.hasPrefix("KN") {
			return .bnp
		}

			// Citi
		if w.hasPrefix("CG") || w.hasPrefix("CV") || w.hasPrefix("HC") || w.hasPrefix("DA") {
			return .citi
		}

			// DZ Bank
		if w.hasPrefix("DG") || w.hasPrefix("DD") || w.hasPrefix("DM") {
			return .dzbank
		}

			// Goldman Sachs
		if w.hasPrefix("GD") || w.hasPrefix("GS") {
			return .goldman
		}

			// HSBC
		if w.hasPrefix("HT") || w.hasPrefix("HM") {
			return .hsbc
		}

			// ING Markets
		if w.hasPrefix("NL") || w.hasPrefix("A18") || w.hasPrefix("A2") {
			return .ing
		}

			// JP Morgan
		if w.hasPrefix("JM") || w.hasPrefix("JP") || w.hasPrefix("J0") {
			return .jpmorgan
		}

			// Société Générale
		if w.hasPrefix("SD") || w.hasPrefix("SG") || w.hasPrefix("SB") {
			return .societegenerale
		}

			// UBS
		if w.hasPrefix("UB") || w.hasPrefix("UF") || w.hasPrefix("UD") {
			return .ubs
		}

			// Vontobel
		if w.hasPrefix("VT") || w.hasPrefix("VO") || w.hasPrefix("VF") {
			return .vontobel
		}

		return nil
	}
}
