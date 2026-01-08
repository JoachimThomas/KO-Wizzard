import Foundation

	/// Reines Instrument-Modell für KO-/Turbo-/Barrier-Produkte.
	/// Enthält ausschließlich Stammdaten & Zertifikats-Parameter.
	/// KEINE Trade- oder Journal-Daten.
struct Instrument: Identifiable, Codable, Equatable {
		// Primär
	var id: UUID = UUID()
	var lastModified: Date? = nil

		// Basisdaten
	var name: String = ""                  // Anzeigename (kann Engine/Store setzen)
	var assetClass: AssetClass = .none
	var subgroup: Subgroup? = nil          // z. B. .dax, .eurUsd
	var direction: Direction = .none
	var emittent: Emittent = .none
	var isin: String = ""

		// Zertifikats-Parameter (als String gespeichert)
	var basispreis: String = ""
	var koSchwelle: String = ""
	var bezugsverhaeltnis: String = ""     // z. B. "1", "0,1", "0,01"
	var aufgeld: String = ""

		// Underlying-Name (z. B. "DAX", "Dow Jones", "EUR/USD")
		// Kann identisch mit subgroup.displayName sein, muss aber nicht
	var underlyingName: String = ""

		// Flags
	var isFavorite: Bool = false
}

	// MARK: - Defaults

extension Instrument {

	static func empty() -> Instrument {
		Instrument(
			id: UUID(),
			lastModified: nil,
			name: "",
			assetClass: .none,
			subgroup: nil,
			direction: .none,
			emittent: .none,
			isin: "",
			basispreis: "",
			koSchwelle: "",
			bezugsverhaeltnis: "",
			aufgeld: "",
			underlyingName: "",
			isFavorite: false
		)
	}
}

	// MARK: - Parsing / Formatting

extension Instrument {

		/// Tolerant: akzeptiert "1.234,56", "1 234,56", "1234.56"
	static func parseNumber(_ s: String) -> Double? {
		let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
		if t.isEmpty { return nil }

			// zuerst mit Locale versuchen
		let nf = NumberFormatter()
		nf.locale = Locale.current
		nf.numberStyle = .decimal
		if let n = nf.number(from: t)?.doubleValue {
			return n
		}

			// Fallback: alles vereinheitlichen
		let unified = t
			.replacingOccurrences(of: " ", with: "")
			.replacingOccurrences(of: ",", with: ".")
		return Double(unified)
	}

	static func compact(_ x: Double?, maxFractionDigits: Int = 4) -> String {
		guard let x = x else { return "" }
		if x.rounded(.towardZero) == x {
			return String(format: "%.0f", x)
		}
		let s = String(format: "%.\(maxFractionDigits)f", x)
			// nachträglich Nullen weg
		return s
			.replacingOccurrences(of: "(\\.[0-9]*?)0+$",
								  with: "$1",
								  options: .regularExpression)
			.replacingOccurrences(of: "\\.$",
								  with: "",
								  options: .regularExpression)
	}
}

	// MARK: - Computed Values

extension Instrument {

		/// Basispreis als Double
	var basispreisValue: Double? {
		Self.parseNumber(basispreis)
	}

		/// KO-Schwelle als Double (fällt auf Basispreis zurück, falls leer)
	var koSchwelleValue: Double? {
		let source = koSchwelle.isEmpty ? basispreis : koSchwelle
		return Self.parseNumber(source)
	}

		/// Bezugsverhältnis als Double
	var bezugsverhaeltnisValue: Double? {
		Self.parseNumber(bezugsverhaeltnis)
	}

		/// Aufgeld als Double
	var aufgeldValue: Double? {
		Self.parseNumber(aufgeld)
	}

		/// KO-Distanz in Prozent bezogen auf den Underlying-Kurs
	func koDistancePercent(underlying: Double?) -> Double? {
		guard let u = underlying,
			  let ko = koSchwelleValue,
			  abs(u) > 1e-12 else { return nil }
		return abs((u - ko) / u) * 100.0
	}

		/// Vorschlag für den Anzeigenamen (z.B. in Listen/Sidebar)
	func suggestedSidebarTitle() -> String {
		let dir = direction.displayName
		let bp  = Instrument.compact(basispreisValue)

		if !underlyingName.trimmingCharacters(in: .whitespaces).isEmpty {
			return "\(underlyingName) \(dir) \(bp)"
		}
		if !isin.trimmingCharacters(in: .whitespaces).isEmpty {
			return "\(isin.uppercased()) \(dir) \(bp)"
		}
		return "\(emittent.displayName) \(dir) \(bp)"
	}
}
