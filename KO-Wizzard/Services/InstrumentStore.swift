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

	var instrumentCount: Int {
		instruments.count
	}

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

		// MARK: - Helper

	func allInstruments() -> [Instrument] {
		instruments
	}

#if DEBUG
	private func seedDummyInstrumentsIfNeeded() {
		var counter = 0
		let baseDate = Date()
		let underlyingsForAktie = ["Siemens", "SAP", "BMW"]

		func formatBasis(_ value: Double) -> String {
			if value < 10 {
				return String(format: "%.3f", value)
			}
			if value < 1000 {
				return String(format: "%.2f", value)
			}
			return String(format: "%.0f", value)
		}

		func baseValue(for subgroup: Subgroup?, assetClass: AssetClass, index: Int) -> Double {
			if let subgroup {
				switch subgroup {
					case .dax: return 16000 + Double(index * 35)
					case .dow: return 38000 + Double(index * 60)
					case .sp500: return 4500 + Double(index * 10)
					case .nasdaq: return 15000 + Double(index * 45)
					case .russell2000: return 2000 + Double(index * 8)
					case .eurUsd: return 1.08 + Double(index) * 0.002
					case .usdJpy: return 145 + Double(index) * 0.2
					case .gbpUsd: return 1.27 + Double(index) * 0.002
					case .oil: return 80 + Double(index) * 0.5
					case .gas: return 2.5 + Double(index) * 0.1
					case .gold: return 2000 + Double(index) * 5
					case .bitcoinUsd: return 43000 + Double(index) * 250
					case .ethereumUsd: return 2300 + Double(index) * 40
				}
			}
			switch assetClass {
				case .aktie: return 120 + Double(index * 4)
				case .igBarrier: return 5000 + Double(index * 30)
				default: return 1000 + Double(index * 25)
			}
		}

		func sanitizeIdentifier(_ value: String) -> String {
			value
				.replacingOccurrences(of: " ", with: "_")
				.replacingOccurrences(of: "/", with: "-")
				.replacingOccurrences(of: "–", with: "-")
		}

		func makeInstrument(
			assetClass: AssetClass,
			subgroup: Subgroup?,
			underlying: String,
			direction: Direction,
			index: Int
		) -> Instrument {
			var inst = Instrument.empty()
			inst.assetClass = assetClass
			inst.subgroup = subgroup
			inst.underlyingName = underlying
			inst.emittent = assetClass == .igBarrier ? .igMarkets : .hsbc
			inst.direction = direction
			let basis = baseValue(for: subgroup, assetClass: assetClass, index: index)
			inst.basispreis = formatBasis(basis)
			inst.koSchwelle = inst.basispreis
			inst.bezugsverhaeltnis = "100"
			inst.aufgeld = "10"
			let token = sanitizeIdentifier(underlying)
			inst.isin = "DUMMY_\(token)_\(direction.rawValue)_\(counter)"
			inst.name = "DUMMY \(underlying) \(direction.displayName) \(inst.basispreis)"
			inst.isFavorite = index % 5 == 0
			inst.lastModified = baseDate.addingTimeInterval(-Double(counter * 60))
			counter += 1
			return inst
		}

		func addIfNeeded(_ instrument: Instrument) {
			add(instrument)
		}

		func hasInstrument(assetClass: AssetClass, subgroup: Subgroup, direction: Direction) -> Bool {
			instruments.contains { inst in
				inst.assetClass == assetClass
				&& inst.subgroup == subgroup
				&& inst.direction == direction
			}
		}

		func hasInstrumentUnderlying(assetClass: AssetClass, underlying: String, direction: Direction) -> Bool {
			instruments.contains { inst in
				inst.assetClass == assetClass
				&& inst.subgroup == nil
				&& inst.underlyingName == underlying
				&& inst.direction == direction
			}
		}

		for assetClass in AssetClass.allCases where assetClass != .none {
			let subgroups = AssetClass.subgroupsTyped(for: assetClass)
			if subgroups.isEmpty {
				for (uIndex, underlying) in underlyingsForAktie.enumerated() {
					let baseIndex = uIndex * 10
					if !hasInstrumentUnderlying(assetClass: assetClass, underlying: underlying, direction: .long) {
						addIfNeeded(makeInstrument(
							assetClass: assetClass,
							subgroup: nil,
							underlying: underlying,
							direction: .long,
							index: baseIndex + 1
						))
					}
					if !hasInstrumentUnderlying(assetClass: assetClass, underlying: underlying, direction: .short) {
						addIfNeeded(makeInstrument(
							assetClass: assetClass,
							subgroup: nil,
							underlying: underlying,
							direction: .short,
							index: baseIndex + 2
						))
					}
				}
			} else {
				for (sIndex, subgroup) in subgroups.enumerated() {
					let underlying = subgroup.displayName
					let baseIndex = sIndex * 10
					if !hasInstrument(assetClass: assetClass, subgroup: subgroup, direction: .long) {
						addIfNeeded(makeInstrument(
							assetClass: assetClass,
							subgroup: subgroup,
							underlying: underlying,
							direction: .long,
							index: baseIndex + 1
						))
					}
					if !hasInstrument(assetClass: assetClass, subgroup: subgroup, direction: .short) {
						addIfNeeded(makeInstrument(
							assetClass: assetClass,
							subgroup: subgroup,
							underlying: underlying,
							direction: .short,
							index: baseIndex + 2
						))
					}
				}
			}
		}
	}
#endif
}
