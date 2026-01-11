//
//  InstrumentDraftController.swift
//  KO-Wizzard
//

import Foundation
import Combine

final class InstrumentDraftController: ObservableObject {

	enum InstrumentCreationStep: Hashable {
		case assetClass
		case subgroup
		case emittent
		case direction
		case isin
		case basispreis
		case bezugsverhaeltnis
		case aufgeld
		case favorite
		case done
	}

	enum ImportState {
		case idle
		case awaitingClipboard
		case readyToImport
	}

	@Published var draftInstrument: Instrument = .empty()
	@Published var creationStep: InstrumentCreationStep = .assetClass
	@Published var editingReturnStep: InstrumentCreationStep? = nil
	@Published var editingTargetID: UUID? = nil
	@Published var importState: ImportState = .idle
	@Published var importedRawText: String = ""

	let allowedEditSteps: Set<InstrumentCreationStep> = [
		.isin,
		.basispreis,
		.bezugsverhaeltnis,
		.aufgeld,
		.favorite
	]
	let allowedEditStepOrder: [InstrumentCreationStep] = [
		.isin,
		.basispreis,
		.bezugsverhaeltnis,
		.aufgeld,
		.favorite
	]

	var isEditingExistingInstrument: Bool {
		editingTargetID != nil
	}

	var draftNeedsisin: Bool {
		draftInstrument.emittent != .igMarkets
	}

	var draftNeedsRatio: Bool {
		draftInstrument.emittent != .igMarkets
	}

	var draftSubgroups: [Subgroup] {
		AssetClass.subgroupsTyped(for: draftInstrument.assetClass)
	}

	var importButtonTitle: String {
		switch importState {
			case .idle:
				return "Import"
			case .awaitingClipboard:
				return "Von Zwischenablage einfügen"
			case .readyToImport:
				return "Start Import"
		}
	}

	func resetDraft() {
		draftInstrument = .empty()
		creationStep = .assetClass
		editingReturnStep = nil
		editingTargetID = nil
		importState = .idle
		importedRawText = ""
	}

	func sanitizedDecimalInput(old: String, new: String) -> String {
		InputSanitizer.numeric(new)
	}

	func isDraftValid(_ draft: Instrument) -> Bool {
			// 1) Subgroup / UnderlyingName prüfen
		switch draft.assetClass {
			case .index, .fx, .rohstoff, .crypto, .igBarrier:
				if draft.subgroup == nil {
					return false
				}
			case .aktie:
				if draft.underlyingName
					.trimmingCharacters(in: .whitespacesAndNewlines)
					.isEmpty {
					return false
				}
			case .none:
				return false
		}

			// 2) Basispreis prüfen
		let basis = draft.basispreis.trimmingCharacters(in: .whitespacesAndNewlines)
		if basis.isEmpty || basis == "0" || basis == "0,0" || basis == "0,00" {
			return false
		}

			// 3) IG-Barrier: Basis + Subgroup reicht, Rest egal
		if draft.assetClass == .igBarrier {
			return true
		}

			// 4) ISIN-Pflicht (z.B. nicht bei IG)
		if draftNeedsisin {
			if draft.isin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				return false
			}
		}

			// 5) Aufgeld muss gesetzt sein
		let auf = draft.aufgeld.trimmingCharacters(in: .whitespacesAndNewlines)
		if auf.isEmpty {
			return false
		}

			// 6) Bezugsverhältnis-Pflicht, falls nötig
		if draftNeedsRatio {
			let ratio = draft.bezugsverhaeltnis.trimmingCharacters(in: .whitespacesAndNewlines)
			if ratio.isEmpty {
				return false
			}
		}

		return true
	}

	func nextStepAfterAssetClassSelection(
		isEditing: Bool,
		assetClass: AssetClass
	) -> InstrumentCreationStep {
		if isEditing {
			return creationStep
		}
		return .subgroup
	}

	func nextStepAfterDirection(
		isEditing: Bool,
		assetClass: AssetClass,
		needsIsin: Bool
	) -> InstrumentCreationStep {
		if isEditing {
			return creationStep
		}
		if assetClass == .igBarrier {
			return .basispreis
		}
		return needsIsin ? .isin : .basispreis
	}

	func nextStepAfterBasispreis(
		isEditing: Bool,
		assetClass: AssetClass,
		needsRatio: Bool
	) -> InstrumentCreationStep {
		if isEditing {
			return creationStep
		}
		if assetClass == .igBarrier {
			return .favorite
		}
		return needsRatio ? .bezugsverhaeltnis : .aufgeld
	}

	func applyBasicsImport(_ basics: ImportedInstrumentBasics, to draft: inout Instrument) {
		if let ac = basics.assetClass {
			draft.assetClass = ac
		}
		if let subgroupName = basics.subgroup {
			if let subgroupEnum = Subgroup.from(displayName: subgroupName) {
				draft.subgroup = subgroupEnum
				draft.underlyingName = subgroupEnum.displayName
			} else {
					// Fallback: nur Name ins Underlying, Subgroup bleibt nil
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
}
