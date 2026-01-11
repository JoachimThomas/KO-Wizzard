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

	@Published var draftInstrument: Instrument = .empty()
	@Published var creationStep: InstrumentCreationStep = .assetClass
	@Published var editingReturnStep: InstrumentCreationStep? = nil
	@Published var editingTargetID: UUID? = nil

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

	func resetDraft() {
		draftInstrument = .empty()
		creationStep = .assetClass
		editingReturnStep = nil
		editingTargetID = nil
	}

	func sanitizedDecimalInput(old: String, new: String) -> String {
		let replaced = new.replacingOccurrences(of: ".", with: ",")

		let allowed = Set("0123456789,")
		let filtered = replaced.filter { allowed.contains($0) }

		var result = ""
		var commaSeen = false

		for ch in filtered {
			if ch == "," {
				if commaSeen { continue }
				if result.isEmpty { continue }
				commaSeen = true
			}
			result.append(ch)
		}

		return result
	}
}
