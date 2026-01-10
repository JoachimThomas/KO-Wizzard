//
//  InstrumentStore.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 19.11.25.
//
//
//  InstrumentStore.swift
//  KO-Wizard
//
//  Daten-Layer für Instruments:
//  - In-Memory-Verwaltung
//  - JSON-Persistenz im Dokumente-Ordner (ISO8601)
//  - Autosave (debounced)
//  - Minimal-Validierung (keine komplett leeren/„0“-Instrumente)
//

import SwiftUI
import Foundation
import Combine

final class InstrumentStore: ObservableObject {

		// öffentlich lesbar, aber nur intern beschreibbar
	@Published private(set) var instruments: [Instrument] = []

	private let fileURL: URL
	private var cancellables = Set<AnyCancellable>()

		// MARK: - Init

	init(fileURL: URL? = nil) {
		if let url = fileURL {
			self.fileURL = url
		} else {
			let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
			self.fileURL = docs.appendingPathComponent("KO_Wizard_Instruments.json")
		}

		load()
#if DEBUG
		seedDummyInstrumentsIfNeeded()
#endif
		setupAutosave()
	}

		// MARK: - Autosave

	private func setupAutosave() {
		$instruments
			.dropFirst()
			.debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
			.sink { [weak self] _ in
				do {
					try self?.save()
				} catch {
#if DEBUG
					print("❌ InstrumentStore.autosave Fehler: \(error)")
#endif
				}
			}
			.store(in: &cancellables)
	}

		// MARK: - Load / Save

	private func load() {
		let fm = FileManager.default

		if !fm.fileExists(atPath: fileURL.path) {
			print("ℹ️ InstrumentStore.load: Keine Datei gefunden – starte mit leerer Liste.")
			instruments = []
			return
		}

		print("📂 InstrumentStore.load: Datei gefunden.")
		print("📂 Lade Datei -> \(fileURL.path)")

		do {
			let data = try Data(contentsOf: fileURL)
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601

			let decoded = try decoder.decode([Instrument].self, from: data)
			print("✅ Dekodierung OK – \(decoded.count) Einträge")
			instruments = decoded
		} catch {
			print("❌ Fehler beim Laden/Dekodieren der Instrumente: \(error)")
			instruments = []
		}
	}

	func save() throws {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

		let data = try encoder.encode(instruments)
		try data.write(to: fileURL, options: [.atomic])
	}

		// MARK: - Validation

		/// Basispreis & Aufgeld: nur Ziffern + optionales Komma
	private func isValidDecimalString(_ value: String, allowEmpty: Bool = false) -> Bool {
		let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

		if trimmed.isEmpty {
			return allowEmpty ? true : false
		}

		if trimmed == "0" || trimmed == "0,0" || trimmed == "0,00" {
			return false
		}

		let pattern = #"^[0-9]+(,[0-9]+)?$"#
		return trimmed.range(of: pattern, options: .regularExpression) != nil
	}

		/// Minimal-Validierung wie gewünscht:
		/// - Instrument darf nicht komplett leer/0 sein
		/// - Basispreis: Pflicht, nur Zahlen + Komma
		/// - Aufgeld: optional, wenn gesetzt → nur Zahlen + Komma
	func isValid(_ instrument: Instrument) -> Bool {

		let hasSubgroup = (instrument.subgroup != nil)

		let hasIsin = !instrument.isin
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.isEmpty

		let hasUnderlying = !instrument.underlyingName
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.isEmpty

		let hasCoreData = hasSubgroup || hasIsin || hasUnderlying

		guard hasCoreData else {
			return false
		}

		let basisOK = isValidDecimalString(instrument.basispreis, allowEmpty: false)
		let aufgeldOK = isValidDecimalString(instrument.aufgeld, allowEmpty: true)

		return basisOK && aufgeldOK
	}

		// MARK: - CRUD

		/// Fügt ein neues Instrument hinzu und gibt dessen ID zurück.
		/// Validierung wird bewusst NICHT erzwungen – das soll später die Engine entscheiden.
	@discardableResult
	func add(_ instrument: Instrument) -> UUID {
		var x = instrument
		if instruments.contains(where: { $0.id == x.id }) {
			x.id = UUID()
		}
		instruments.append(x)
		return x.id
	}

	func update(_ instrument: Instrument) {
		guard let idx = instruments.firstIndex(where: { $0.id == instrument.id }) else {
			return
		}
		instruments[idx] = instrument
	}

	func delete(_ instrument: Instrument) {
		instruments.removeAll { $0.id == instrument.id }
	}

	func delete(at offsets: IndexSet) {
		instruments.remove(atOffsets: offsets)
	}

	func move(from source: IndexSet, to destination: Int) {
		instruments.move(fromOffsets: source, toOffset: destination)
	}

		// MARK: - Helper

	func allInstruments() -> [Instrument] {
		instruments
	}

#if DEBUG
	private func seedDummyInstrumentsIfNeeded() {
		guard instruments.count < 5 else { return }
		for i in 0..<30 {
			var inst = Instrument.empty()
			inst.assetClass = .index
			inst.subgroup = .dax
			inst.underlyingName = "DAX"
			inst.emittent = .hsbc
			inst.direction = i % 2 == 0 ? .long : .short
			let basis = 14500 + (i * 160 % 5000)
			inst.basispreis = String(format: "%.0f", Double(basis))
			inst.koSchwelle = inst.basispreis
			inst.bezugsverhaeltnis = i % 3 == 0 ? "10" : (i % 3 == 1 ? "20" : "100")
			inst.aufgeld = String(format: "%.2f", 1.5 + Double(i % 7))
			inst.isin = "DUMMY\(100000000 + i)"
			inst.name = "DUMMY DAX \(inst.direction.displayName) \(inst.basispreis)"
			inst.isFavorite = i % 7 == 0
			add(inst)
		}
	}
#endif
}
