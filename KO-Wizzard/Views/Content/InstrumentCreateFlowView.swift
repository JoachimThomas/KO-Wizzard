	//  InstrumentCreateFlowView.swift
	//  KO-Wizzard
	//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

	/// GUIDED CREATE FLOW
	/// Ein Schritt pro Wert. Keine Fehler möglich.
	/// Text-Eingaben (Aktienname, isin, Basispreis, Aufgeld, Ratio-Custom) über ein zentrales Sheet.
struct InstrumentCreateFlowView: View {

	@EnvironmentObject var appState: AppStateEngine

		// Welches Eingabe-Sheet ist aktiv?
	@State private var activeSheet: SheetType?

		// Für Ratio (Bezugsverhältnis)
	@State private var localRatio: RatioOption = .none

		// NEU: eigenes Sheet für Subgroup bei Nicht-Aktie
	@State private var showSubgroupSheet: Bool = false

		// MARK: - Import-Button-State

	private enum ImportState {
		case idle              // Label: "Import"
		case awaitingClipboard // Label: "Von Zwischenablage einfügen"
		case readyToImport     // Label: "Start Import"
	}

	@State private var importState: ImportState = .idle
	@State private var importedRawText: String = ""

	enum SheetType: Identifiable {
		case stockName
		case isin
		case basispreis
		case aufgeld
		case ratioCustom


		var id: String {
			switch self {
				case .stockName:   return "stockName"
				case .isin:         return "isin"
				case .basispreis:  return "basispreis"
				case .aufgeld:     return "aufgeld"
				case .ratioCustom: return "ratioCustom"

			}
		}
	}

	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 16)
				.strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
				.background(
					RoundedRectangle(cornerRadius: 16)
						.fill(Color.secondary.opacity(0.04))
				)

			VStack(alignment: .leading, spacing: 20) {

				HStack {
					Text("Neueingabe – Schritt für Schritt")
						.font(.headline)

					Spacer()

					Button {
						handleImportButtonTap()
					} label: {
						Label(importButtonTitle, systemImage: "arrow.down.doc")
							.font(.system(size: 12, weight: .medium))
					}
					.buttonStyle(.bordered)
				}

				Divider()

				switch appState.creationStep {

					case .assetClass:
						assetClassStep

					case .subgroup:
						subgroupStep

					case .emittent:
						emittentStep

					case .direction:
						directionStep

					case .isin:
						isinStep

					case .basispreis:
						basispreisStep

					case .bezugsverhaeltnis:
						ratioStep

					case .aufgeld:
						aufgeldStep

					case .favorite:
						favoriteStep

					case .done:
						doneStep
				}
			}
			.padding(20)
		}
		.onAppear {
			syncLocalFromDraftIfNeeded()
		}
		.sheet(item: $activeSheet) { sheet in
			sheetContent(for: sheet)
		}
		.sheet(isPresented: $showSubgroupSheet) {
			SubgroupPickerSheet(
				subgroups: appState.draftSubgroups,               // [Subgroup]
				current: appState.draftInstrument.subgroup        // Subgroup?
			) { selected in                                      // Subgroup
				appState.updateDraft { draft in
					draft.subgroup = selected
					draft.underlyingName = selected.displayName   // String für Anzeige
				}

				if isEditing {
					appState.finishEditingStepIfNeeded()
				} else if appState.draftInstrument.assetClass == .igBarrier {
					appState.creationStep = .direction
				} else {
					appState.creationStep = .emittent
				}
			}
		}
	}

		// MARK: - Edit vs Normal Flow

	private var isEditing: Bool {
		appState.editingReturnStep != nil
	}

	private func goNextOrReturn(
		default next: AppStateEngine.InstrumentCreationStep
	) {
		if isEditing {
			appState.finishEditingStepIfNeeded()
		} else {
			appState.creationStep = next
		}
	}

		// MARK: - Steps

	@ViewBuilder
	private var assetClassStep: some View {
		pickerStep(
			title: "1. Assetklasse wählen",
			values: AssetClass.allCases.map { ($0, $0.displayName) },
			selected: nil,
			onSelect: { value in
				appState.updateDraft { draft in
					draft.assetClass = value
					draft.subgroup = nil          // vorher: ""
					draft.underlyingName = ""     // bleibt String, wird später aus Subgroup gesetzt
					
					if value == .igBarrier {
						draft.emittent = .igMarkets
						draft.isin = ""
						draft.bezugsverhaeltnis = ""
						draft.aufgeld = "0"
					} else {
						draft.emittent = .none
						draft.isin = ""
						draft.bezugsverhaeltnis = ""
						draft.aufgeld = ""
					}
				}
				
				goNextOrReturn(default: .subgroup)
			}
		)
	}

	@ViewBuilder
	private var subgroupStep: some View {

		if appState.draftInstrument.assetClass == .aktie {

			VStack(alignment: .leading, spacing: 12) {
				Text("2. Aktienname eingeben")
					.font(.subheadline)
					.foregroundColor(.secondary)

					// Der frei eingegebene Name steckt jetzt ausschließlich in underlyingName
				let name = appState.draftInstrument.underlyingName
					.trimmingCharacters(in: .whitespaces)

				sheetInputButton(
					title: "Aktienname",
					value: name.isEmpty
					? "Noch kein Aktienname eingegeben"
					: name
				) {
					activeSheet = .stockName
				}
			}
			.onAppear {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
					if activeSheet == nil {
						activeSheet = .stockName
					}
				}
			}

		} else {

				// *** NEU: Subgroup per Sheet statt Picker ***
			VStack(alignment: .leading, spacing: 12) {
				Text("2. Subgroup wählen")
					.font(.subheadline)
					.foregroundColor(.secondary)
				
				let subgroupName = appState.draftInstrument.subgroup?.displayName ?? ""
				
				Button {
					showSubgroupSheet = true
				} label: {
					HStack {
						Text(subgroupName.isEmpty
							 ? "Noch keine Subgroup gewählt"
							 : subgroupName)
						Spacer()
						Image(systemName: "chevron.down")
							.foregroundColor(.secondary)
					}
					.padding(8)
					.background(Color.secondary.opacity(0.08))
					.cornerRadius(8)
				}
				.onAppear {
					if isEditing {
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
							showSubgroupSheet = true
						}
					}
				}
			}
		}
	}

	@ViewBuilder
	private var emittentStep: some View {
		if appState.draftInstrument.assetClass == .igBarrier {
			EmptyView()
		} else {
			pickerStep(
				title: "3. Emittent wählen",
				values: Emittent.allCases.map { ($0, $0.displayName) },
				selected: nil,
				onSelect: { value in
					appState.updateDraft {
						$0.emittent = value
						if value == .igMarkets {
							$0.isin = ""
							$0.bezugsverhaeltnis = ""
						}
					}

					goNextOrReturn(default: .direction)
				}
			)
		}
	}

	@ViewBuilder
	private var directionStep: some View {
		pickerStep(
			title: "4. Richtung wählen",
			values: Direction.allCases.map { ($0, $0.displayName) },
			selected: nil,
			onSelect: { value in
				appState.updateDraft { $0.direction = value }

				if isEditing {
					appState.finishEditingStepIfNeeded()
				} else if appState.draftInstrument.assetClass == .igBarrier {
					appState.creationStep = .basispreis
				} else if appState.draftNeedsisin {
					appState.creationStep = .isin
				} else {
					appState.creationStep = .basispreis
				}
			}
		)
	}

	@ViewBuilder
	private var isinStep: some View {
		if appState.draftInstrument.assetClass == .igBarrier {
			EmptyView()
		} else {
			VStack(alignment: .leading, spacing: 12) {
				Text("5. Isin eingeben")
					.font(.subheadline)
					.foregroundColor(.secondary)

				sheetInputButton(
					title: "isin",
					value: appState.draftInstrument.isin.isEmpty
					? "Noch keine Isin eingegeben"
					: appState.draftInstrument.isin
				) {
					activeSheet = .isin
				}
			}
			.onAppear {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
					if activeSheet == nil {
						activeSheet = .isin
					}
				}
			}
		}
	}

	@ViewBuilder
	private var basispreisStep: some View {
		let titleText: String = {
			if appState.draftInstrument.assetClass == .igBarrier {
				return "5. Basispreis eingeben"
			} else if appState.draftNeedsisin {
				return "6. Basispreis eingeben"
			} else {
				return "5. Basispreis eingeben"
			}
		}()

		VStack(alignment: .leading, spacing: 12) {
			Text(titleText)
				.font(.subheadline)
				.foregroundColor(.secondary)

			sheetInputButton(
				title: "Basispreis",
				value: appState.draftInstrument.basispreis.isEmpty
				? "Noch kein Basispreis eingegeben"
				: appState.draftInstrument.basispreis
			) {
				activeSheet = .basispreis
			}
		}
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
				if activeSheet == nil {
					activeSheet = .basispreis
				}
			}
		}
	}

	@ViewBuilder
	private var ratioStep: some View {
		if appState.draftInstrument.assetClass == .igBarrier {
			EmptyView()
		} else {
			VStack(alignment: .leading, spacing: 12) {
				Text("Bezugsverhältnis wählen")
					.font(.subheadline)
					.foregroundColor(.secondary)

				Picker("", selection: $localRatio) {
					ForEach(RatioOption.allCases) { opt in
						Text(opt.displayName).tag(opt)
					}
				}
				.pickerStyle(.menu)

				.onChange(of: localRatio) { _, newValue in
					switch newValue {
						case .none:
							appState.updateDraft { $0.bezugsverhaeltnis = "" }
							goNextOrReturn(default: .aufgeld)

						case .oneToOne, .oneToTen, .oneToHundred, .oneToThousand:
							appState.updateDraft { $0.bezugsverhaeltnis = newValue.numericValue }
							goNextOrReturn(default: .aufgeld)

						case .custom:
							activeSheet = .ratioCustom
					}
				}
			}
			.onAppear {
				localRatio = ratioOptionForValue(appState.draftInstrument.bezugsverhaeltnis)
			}
		}
	}

	@ViewBuilder
	private var aufgeldStep: some View {
		if appState.draftInstrument.assetClass == .igBarrier {
			VStack(alignment: .leading, spacing: 12) {
				Text("Aufgeld wird für IG-Barrier automatisch auf 0 gesetzt.")
					.font(.subheadline)
					.foregroundColor(.secondary)

				HStack {
					Spacer()
					Button("Weiter") {
						goNextOrReturn(default: .favorite)
					}
					.buttonStyle(.borderedProminent)
				}
			}
		} else {
			VStack(alignment: .leading, spacing: 12) {
				Text("Aufgeld eingeben")
					.font(.subheadline)
					.foregroundColor(.secondary)

				sheetInputButton(
					title: "Aufgeld",
					value: appState.draftInstrument.aufgeld.isEmpty
					? "Noch kein Aufgeld eingegeben"
					: appState.draftInstrument.aufgeld
				) {
					activeSheet = .aufgeld
				}
			}
			.onAppear {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
					if activeSheet == nil {
						activeSheet = .aufgeld
					}
				}
			}
		}
	}

	private var favoriteStep: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Favorit markieren")
				.font(.subheadline)
				.foregroundColor(.secondary)

			Toggle("Favorit", isOn: Binding(
				get: { appState.draftInstrument.isFavorite },
				set: { newValue in
					appState.updateDraft { $0.isFavorite = newValue }
				}
			))

			HStack {
				Spacer()
				Button("Weiter") {
					goNextOrReturn(default: .done)
				}
				.buttonStyle(.borderedProminent)
			}
		}
	}

	private var doneStep: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Instrument fertig erfasst.")
				.font(.subheadline)
				.foregroundColor(.secondary)

			if !isDraftValid {
				Text("Bitte alle Pflichtfelder sinnvoll ausfüllen (keine leeren / Defaultwerte).")
					.font(.footnote)
					.foregroundColor(.red.opacity(0.8))
			}

			HStack {
				Spacer()
				Button("Instrument speichern") {
					appState.addInstrument(appState.draftInstrument)
					appState.workspaceMode = .instrumentsShowAndChange
					appState.creationStep = .assetClass
					appState.resetDraftInstrument()
				}
				.buttonStyle(.borderedProminent)
				.disabled(!isDraftValid)
			}
		}
	}

		// MARK: Sheet Inhalte

	@ViewBuilder
	private func sheetContent(for type: SheetType) -> some View {
		switch type {

			case .stockName:
				ValueInputSheet(
					title: "Aktienname",
					message: "Bitte geben Sie den Aktiennamen ein!",
					kind: .stockName,
					initialValue: appState.draftInstrument.underlyingName
				) { value in
					appState.updateDraft {
						$0.subgroup = nil                 // kein Enum, freier Aktienname
						$0.underlyingName = value         // hier steht der eingegebene Name
					}
					activeSheet = nil
				

					if isEditing {
						appState.finishEditingStepIfNeeded()
					} else {
						appState.creationStep = .emittent
					}
				} onCancel: {
					activeSheet = nil
				}

			case .isin:
				ValueInputSheet(
					title: "isin",
					message: "Bitte geben Sie die isin ein.",
					kind: .isin,
					initialValue: appState.draftInstrument.isin
				) { value in
					appState.updateDraft { $0.isin = value }
					activeSheet = nil

					if isEditing {
						appState.finishEditingStepIfNeeded()
					} else {
						appState.creationStep = .basispreis
					}
				} onCancel: {
					activeSheet = nil
				}

			case .basispreis:
				ValueInputSheet(
					title: "Basispreis",
					message: "Bitte geben Sie den Basispreis ein.",
					kind: .numeric,
					initialValue: appState.draftInstrument.basispreis
				) { value in
					appState.updateDraft { $0.basispreis = value }
					activeSheet = nil

					if isEditing {
						appState.finishEditingStepIfNeeded()
					} else if appState.draftInstrument.assetClass == .igBarrier {
						appState.creationStep = .favorite
					} else if appState.draftNeedsRatio {
						appState.creationStep = .bezugsverhaeltnis
					} else {
						appState.creationStep = .aufgeld
					}
				} onCancel: {
					activeSheet = nil
				}

			case .aufgeld:
				ValueInputSheet(
					title: "Aufgeld",
					message: "Bitte geben Sie das Aufgeld ein.",
					kind: .numeric,
					initialValue: appState.draftInstrument.aufgeld
				) { value in
					appState.updateDraft { $0.aufgeld = value }
					activeSheet = nil

					goNextOrReturn(default: .favorite)
				} onCancel: {
					activeSheet = nil
				}

			case .ratioCustom:
				ValueInputSheet(
					title: "Individuelles Bezugsverhältnis",
					message: "Bitte geben Sie den Nenner des Bezugsverhältnisses ein (z. B. 10 für 1 : 10).",
					kind: .numeric,
					initialValue: customRatioInitialValue(from: appState.draftInstrument.bezugsverhaeltnis)
				) { value in
					let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
					let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
					if let denom = Double(normalized), denom > 0 {
						let display: String
						if floor(denom) == denom {
							display = "1 : \(Int(denom))"
						} else {
							display = "1 : \(denom)"
						}
						appState.updateDraft { $0.bezugsverhaeltnis = display }
					}
					activeSheet = nil

					goNextOrReturn(default: .aufgeld)
				} onCancel: {
					activeSheet = nil
					localRatio = ratioOptionForValue(appState.draftInstrument.bezugsverhaeltnis)
				}

		}
	}

		// MARK: - Helpers


		// MARK: - Import-Button Logik

	private var importButtonTitle: String {
		switch importState {
			case .idle:
				return "Import"
			case .awaitingClipboard:
				return "Von Zwischenablage einfügen"
			case .readyToImport:
				return "Start Import"
		}
	}

	private func handleImportButtonTap() {
		switch importState {

			case .idle:
					// Schritt 1 → in "Clipboard holen"-Modus schalten
				importState = .awaitingClipboard

			case .awaitingClipboard:
					// Schritt 2 → Text aus Zwischenablage holen
				let clipped = readClipboardText().trimmingCharacters(in: .whitespacesAndNewlines)
				guard !clipped.isEmpty else {
						// nichts in der Zwischenablage → zurück auf idle
					importState = .idle
					return
				}
				importedRawText = clipped
				importState = .readyToImport

			case .readyToImport:
					// Schritt 3 → Parser starten, Draft füllen
				runBasicsImport(with: importedRawText, appState: appState)
					// Button wieder zurücksetzen
				importedRawText = ""
				importState = .idle
		}
	}


	private var isDraftValid: Bool {
		let d = appState.draftInstrument

			// 1) Subgroup / UnderlyingName prüfen
		switch d.assetClass {

					// Klassen mit fest definierten Subgroups (Enum-Pflicht)
			case .index, .fx, .rohstoff, .crypto, .igBarrier:
				if d.subgroup == nil {
					return false
				}

					// Aktie → freier Name im Underlying zwingend
			case .aktie:
				if d.underlyingName
					.trimmingCharacters(in: .whitespacesAndNewlines)
					.isEmpty {
					return false
				}

			case .none:
				return false
		}

			// 2) Basispreis prüfen
		let basis = d.basispreis.trimmingCharacters(in: .whitespacesAndNewlines)
		if basis.isEmpty || basis == "0" || basis == "0,0" || basis == "0,00" {
			return false
		}

			// 3) IG-Barrier: Basis + Subgroup reicht, Rest egal
		if d.assetClass == .igBarrier {
			return true
		}

			// 4) ISIN-Pflicht (z.B. nicht bei IG)
		if appState.draftNeedsisin {
			if d.isin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				return false
			}
		}

			// 5) Aufgeld muss gesetzt sein
		let auf = d.aufgeld.trimmingCharacters(in: .whitespacesAndNewlines)
		if auf.isEmpty {
			return false
		}

			// 6) Bezugsverhältnis-Pflicht, falls nötig
		if appState.draftNeedsRatio {
			let ratio = d.bezugsverhaeltnis.trimmingCharacters(in: .whitespacesAndNewlines)
			if ratio.isEmpty {
				return false
			}
		}

		return true
	}

	private func syncLocalFromDraftIfNeeded() {
		localRatio = ratioOptionForValue(appState.draftInstrument.bezugsverhaeltnis)
	}
}
private func readClipboardText() -> String {
#if os(iOS)
	return UIPasteboard.general.string ?? ""
#elseif os(macOS)
	return NSPasteboard.general.string(forType: .string) ?? ""
#else
	return ""
#endif
}

private func runBasicsImport(with raw: String, appState: AppStateEngine) {
	let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
	guard !trimmed.isEmpty else { return }

		// nutzt dein Utility
	let basics = BasicsImportParser.parse(raw: trimmed)

	appState.updateDraft { draft in
		if let ac = basics.assetClass {
			draft.assetClass = ac
		}
		if let subgroupName = basics.subgroup {
			if let subgroupEnum = Subgroup.from(displayName: subgroupName) {
				draft.subgroup = subgroupEnum
				draft.underlyingName = subgroupEnum.displayName
			} else {
					// Fallback: wir speichern nur den Namen ins Underlying,
					// Subgroup bleibt nil, falls der String keiner bekannten Subgroup entspricht
				draft.subgroup = nil
				draft.underlyingName = subgroupName
			}
		}
		if let dir = basics.direction {
			draft.direction = dir
		}
		if let em = basics.emittent {
			draft.emittent = em
		}
		if let isin = basics.isin {
			draft.isin = isin
		}
		
		if let basis = basics.basispreis {
			draft.basispreis = basis
		}
		if let ratio = basics.ratioDisplay {
			draft.bezugsverhaeltnis = ratio
		}
		if let auf = basics.aufgeld {
			draft.aufgeld = auf
		}
	}

		// Flow „wie gehabt“ weiterführen:
		// Hier z.B. direkt zu Favorit springen,
		// oder wenn du willst zu .done.
	appState.creationStep = .favorite
}
	

