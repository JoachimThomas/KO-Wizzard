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
			VStack(alignment: .leading, spacing: 20) {

				HStack {
					Text("Neueingabe – Schritt für Schritt")
						.font(.menlo(textStyle: .headline))
						.fontWeight(.bold)
						.contentEmphasis()

					Spacer()

					Button {
						appState.handleImportButtonTap()
					} label: {
						Label(appState.draft.importButtonTitle, systemImage: "arrow.down.doc")
							.font(.custom("Menlo", size: 12).weight(.medium))
							.contentEmphasis()
					}
					.buttonStyle(.bordered)
				}

				Divider()

				switch appState.draft.creationStep {

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
        .frame(maxWidth: .infinity, alignment: .leading) 
		.workspaceGradientBackground(cornerRadius: 16)
		.font(.menlo(textStyle: .body))
		.onAppear {
			appState.ensureAllowedEditStepIfNeeded()
		}
		.onChange(of: appState.draft.creationStep) { _, _ in
			appState.ensureAllowedEditStepIfNeeded()
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
				current: appState.draft.draftInstrument.subgroup        // Subgroup?
			) { selected in                                      // Subgroup
				appState.updateDraft { draft in
					draft.subgroup = selected
					draft.underlyingName = selected.displayName   // String für Anzeige
				}

				if appState.isEditingExistingInstrument {
					appState.finishEditingStepIfNeeded()
				} else if appState.draft.draftInstrument.assetClass == .igBarrier {
					appState.draft.creationStep = .direction
				} else {
					appState.draft.creationStep = .emittent
				}
			}
		}
	}

		// MARK: - Edit vs Normal Flow

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
				
				appState.advanceDraftOrReturn(default: .subgroup)
			}
		)
	}

	@ViewBuilder
	private var subgroupStep: some View {

		if appState.draft.draftInstrument.assetClass == .aktie {

			VStack(alignment: .leading, spacing: 12) {
				Text("2. Aktienname eingeben")
					.font(.menlo(textStyle: .subheadline))
					.foregroundColor(.secondary)

					// Der frei eingegebene Name steckt jetzt ausschließlich in underlyingName
				let name = appState.draft.draftInstrument.underlyingName
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
					.font(.menlo(textStyle: .subheadline))
					.foregroundColor(.secondary)
				
				let subgroupName = appState.draft.draftInstrument.subgroup?.displayName ?? ""
				
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
					if appState.isEditingExistingInstrument {
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
		if appState.draft.draftInstrument.assetClass == .igBarrier {
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

					appState.advanceDraftOrReturn(default: .direction)
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

				if appState.isEditingExistingInstrument {
					appState.finishEditingStepIfNeeded()
				} else if appState.draft.draftInstrument.assetClass == .igBarrier {
					appState.draft.creationStep = .basispreis
				} else if appState.draftNeedsisin {
					appState.draft.creationStep = .isin
				} else {
					appState.draft.creationStep = .basispreis
				}
			}
		)
	}

	@ViewBuilder
	private var isinStep: some View {
		if appState.draft.draftInstrument.assetClass == .igBarrier {
			EmptyView()
		} else {
			VStack(alignment: .leading, spacing: 12) {
				Text("5. Isin eingeben")
					.font(.menlo(textStyle: .subheadline))
					.foregroundColor(.secondary)

				sheetInputButton(
					title: "isin",
					value: appState.draft.draftInstrument.isin.isEmpty
					? "Noch keine Isin eingegeben"
					: appState.draft.draftInstrument.isin
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
			if appState.draft.draftInstrument.assetClass == .igBarrier {
				return "5. Basispreis eingeben"
			} else if appState.draftNeedsisin {
				return "6. Basispreis eingeben"
			} else {
				return "5. Basispreis eingeben"
			}
		}()

		VStack(alignment: .leading, spacing: 12) {
			Text(titleText)
				.font(.menlo(textStyle: .subheadline))
				.foregroundColor(.secondary)

			sheetInputButton(
				title: "Basispreis",
				value: appState.draft.draftInstrument.basispreis.isEmpty
				? "Noch kein Basispreis eingegeben"
				: appState.draft.draftInstrument.basispreis
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
		if appState.draft.draftInstrument.assetClass == .igBarrier {
			EmptyView()
		} else {
			VStack(alignment: .leading, spacing: 12) {
				Text("Bezugsverhältnis wählen")
					.font(.menlo(textStyle: .subheadline))
					.foregroundColor(.secondary)

				Picker("", selection: $localRatio) {
					ForEach(RatioOption.allCases) { opt in
						Text(opt.displayName).tag(opt)
					}
				}
				.pickerStyle(.menu)

				.onChange(of: localRatio) { _, newValue in
					if appState.isEditingExistingInstrument {
						return
					}
					switch newValue {
						case .none:
							appState.updateDraft { $0.bezugsverhaeltnis = "" }
							appState.advanceDraftOrReturn(default: .aufgeld)

						case .oneToOne, .oneToTen, .oneToHundred, .oneToThousand:
							appState.updateDraft { $0.bezugsverhaeltnis = newValue.numericValue }
							appState.advanceDraftOrReturn(default: .aufgeld)

						case .custom:
							activeSheet = .ratioCustom
					}
				}

				if appState.isEditingExistingInstrument {
					HStack {
						Spacer()
						Button("Übernehmen") {
							let currentValue = appState.draft.draftInstrument.bezugsverhaeltnis
								.trimmingCharacters(in: .whitespacesAndNewlines)

							if localRatio == .custom && currentValue.isEmpty {
								activeSheet = .ratioCustom
								return
							}

							switch localRatio {
								case .none:
									appState.updateDraft { $0.bezugsverhaeltnis = "" }
								case .oneToOne, .oneToTen, .oneToHundred, .oneToThousand:
									appState.updateDraft { $0.bezugsverhaeltnis = localRatio.numericValue }
								case .custom:
									break
							}

							appState.finishEditingStepIfNeeded()
						}
						.buttonStyle(.borderedProminent)
					}
				}
			}
			.onAppear {
				localRatio = ratioOptionForValue(appState.draft.draftInstrument.bezugsverhaeltnis)
			}
		}
	}

	@ViewBuilder
	private var aufgeldStep: some View {
		if appState.draft.draftInstrument.assetClass == .igBarrier {
			VStack(alignment: .leading, spacing: 12) {
				Text("Aufgeld wird für IG-Barrier automatisch auf 0 gesetzt.")
					.font(.menlo(textStyle: .subheadline))
					.foregroundColor(.secondary)

				HStack {
					Spacer()
					Button("Weiter") {
						appState.advanceDraftOrReturn(default: .favorite)
					}
					.buttonStyle(.borderedProminent)
				}
			}
		} else {
			VStack(alignment: .leading, spacing: 12) {
				Text("Aufgeld eingeben")
					.font(.menlo(textStyle: .subheadline))
					.foregroundColor(.secondary)

				sheetInputButton(
					title: "Aufgeld",
					value: appState.draft.draftInstrument.aufgeld.isEmpty
					? "Noch kein Aufgeld eingegeben"
					: appState.draft.draftInstrument.aufgeld
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
				.font(.menlo(textStyle: .subheadline))
				.foregroundColor(.secondary)

			Toggle("Favorit", isOn: Binding(
				get: { appState.draft.draftInstrument.isFavorite },
				set: { newValue in
					appState.updateDraft { $0.isFavorite = newValue }
				}
			))

			HStack {
				Spacer()
				Button("Weiter") {
					if appState.isEditingExistingInstrument {
						appState.draft.creationStep = .done
					} else {
						appState.advanceDraftOrReturn(default: .done)
					}
				}
				.buttonStyle(.borderedProminent)
			}
		}
	}

	private var doneStep: some View {
		VStack(alignment: .leading, spacing: 12) {
			if appState.isEditingExistingInstrument {
				Text("Änderungen übernehmen?")
					.font(.menlo(textStyle: .subheadline))
					.foregroundColor(.secondary)

				HStack {
					Spacer()
					Button("Verwerfen") {
						appState.discardEditSession()
					}
					Button("Speichern") {
						appState.commitEditSession()
					}
					.buttonStyle(.borderedProminent)
				}
			} else {
				Text("Instrument fertig erfasst.")
					.font(.menlo(textStyle: .subheadline))
					.foregroundColor(.secondary)

				if !appState.isCurrentDraftValid {
					Text("Bitte alle Pflichtfelder sinnvoll ausfüllen (keine leeren / Defaultwerte).")
						.font(.menlo(textStyle: .footnote))
						.foregroundColor(.red.opacity(0.8))
				}

				HStack {
					Spacer()
					Button("Instrument speichern") {
						appState.doneStep()
					}
					.buttonStyle(.borderedProminent)
					.disabled(!appState.isCurrentDraftValid)
				}
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
					initialValue: appState.draft.draftInstrument.underlyingName
				) { value in
					appState.updateDraft {
						$0.subgroup = nil                 // kein Enum, freier Aktienname
						$0.underlyingName = value         // hier steht der eingegebene Name
					}
					activeSheet = nil
				

					if appState.isEditingExistingInstrument {
						appState.finishEditingStepIfNeeded()
					} else {
						appState.draft.creationStep = .emittent
					}
				} onCancel: {
					activeSheet = nil
					appState.cancelEditIfNeeded()
				}

			case .isin:
				ValueInputSheet(
					title: "isin",
					message: "Bitte geben Sie die isin ein.",
					kind: .isin,
					initialValue: appState.draft.draftInstrument.isin
				) { value in
					appState.updateDraft { $0.isin = value }
					activeSheet = nil

					if appState.isEditingExistingInstrument {
						appState.finishEditingStepIfNeeded()
					} else {
						appState.draft.creationStep = .basispreis
					}
				} onCancel: {
					activeSheet = nil
					appState.cancelEditIfNeeded()
				}

			case .basispreis:
				ValueInputSheet(
					title: "Basispreis",
					message: "Bitte geben Sie den Basispreis ein.",
					kind: .numeric,
					initialValue: appState.draft.draftInstrument.basispreis
				) { value in
					appState.updateDraft { $0.basispreis = value }
					activeSheet = nil

					if appState.isEditingExistingInstrument {
						appState.finishEditingStepIfNeeded()
					} else if appState.draft.draftInstrument.assetClass == .igBarrier {
						appState.draft.creationStep = .favorite
					} else if appState.draftNeedsRatio {
						appState.draft.creationStep = .bezugsverhaeltnis
					} else {
						appState.draft.creationStep = .aufgeld
					}
				} onCancel: {
					activeSheet = nil
					appState.cancelEditIfNeeded()
				}

			case .aufgeld:
				ValueInputSheet(
					title: "Aufgeld",
					message: "Bitte geben Sie das Aufgeld ein.",
					kind: .numeric,
					initialValue: appState.draft.draftInstrument.aufgeld
				) { value in
					appState.updateDraft { $0.aufgeld = value }
					activeSheet = nil

					appState.advanceDraftOrReturn(default: .favorite)
				} onCancel: {
					activeSheet = nil
					appState.cancelEditIfNeeded()
				}

			case .ratioCustom:
				ValueInputSheet(
					title: "Individuelles Bezugsverhältnis",
					message: "Bitte geben Sie den Nenner des Bezugsverhältnisses ein (z. B. 10 für 1 : 10).",
					kind: .numeric,
					initialValue: customRatioInitialValue(from: appState.draft.draftInstrument.bezugsverhaeltnis)
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

					appState.advanceDraftOrReturn(default: .aufgeld)
				} onCancel: {
					activeSheet = nil
					localRatio = ratioOptionForValue(appState.draft.draftInstrument.bezugsverhaeltnis)
					appState.cancelEditIfNeeded()
				}

		}
	}

		// MARK: - Helpers
	private func syncLocalFromDraftIfNeeded() {
		localRatio = ratioOptionForValue(appState.draft.draftInstrument.bezugsverhaeltnis)
	}
}
