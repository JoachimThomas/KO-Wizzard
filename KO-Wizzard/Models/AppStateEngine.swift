import Foundation
import SwiftUI
import Combine
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

	/// Zentrale Engine der KO-Wizard App
	/// - Hält globalen State (Landing, Workspace-Modi)
	/// - Beinhaltet Stores (Instrumente, später Trades)
	/// - Views greifen ausschließlich über diese Engine zu

final class AppStateEngine: ObservableObject {

	// MARK: - Controllers

	let navigation: NavigationController
	let draft: InstrumentDraftController
	var list: InstrumentListController
	let collapse: SidebarCollapseController

	// MARK: - Stores

	let instrumentStore: InstrumentStore
		// später:
		// let tradeStore: TradeStore

	// MARK: - Auswahl

	/// Aktuell ausgewähltes Instrument (per ID)
	@Published var selectedInstrumentID: UUID? = nil

	/// Zuletzt gespeichertes Instrument (Neu oder geändert)
	@Published var lastSavedInstrumentID: UUID? = nil
	private static let lastSavedInstrumentIDKey = "lastSavedInstrumentID"

	/// Zuletzt im Show-&-Change-Modus angezeigtes Instrument
	@Published var lastShownInstrumentID: UUID? = nil

	private var cancellables = Set<AnyCancellable>()

	// MARK: - Init

	init(instrumentStore: InstrumentStore = InstrumentStore()) {
		self.instrumentStore = instrumentStore
		self.navigation = NavigationController()
		self.draft = InstrumentDraftController()
		let listController = InstrumentListController(instrumentStore: instrumentStore)
		self.list = listController
		self.collapse = SidebarCollapseController(instrumentsProvider: { [weak listController] in
			listController?.filteredInstruments ?? []
		})

		bindControllers()

		if let raw = UserDefaults.standard.string(forKey: Self.lastSavedInstrumentIDKey),
		   let id = UUID(uuidString: raw) {
			lastSavedInstrumentID = id
		}
		if selectedInstrumentID == nil, let recent = mostRecentlyModifiedInstrument() {
			selectedInstrumentID = recent.id
			if lastSavedInstrumentID == nil {
				lastSavedInstrumentID = recent.id
				persistLastSavedInstrumentID(recent.id)
			}
		}
		collapse.setInitialCollapseState(selectedInstrument: selectedInstrument)
	}

	private func bindControllers() {
		navigation.objectWillChange
			.sink { [weak self] _ in
				self?.objectWillChange.send()
			}
			.store(in: &cancellables)

		draft.objectWillChange
			.sink { [weak self] _ in
				self?.objectWillChange.send()
			}
			.store(in: &cancellables)

		list.objectWillChange
			.sink { [weak self] _ in
				self?.objectWillChange.send()
			}
			.store(in: &cancellables)

		collapse.objectWillChange
			.sink { [weak self] _ in
				self?.objectWillChange.send()
			}
			.store(in: &cancellables)

		instrumentStore.objectWillChange
			.sink { [weak self] _ in
				self?.objectWillChange.send()
			}
			.store(in: &cancellables)
	}

	// MARK: - Navigation

	// Landing-Button: "Instrument anlegen"
	func startInstrumentCreation() {
		enterCreateMode(selectLastSaved: false)
	}

	// Landing-Button: "Instrument anzeigen"
	func switchToInstruments() {
		endEditSessionForNavigation(keepSelection: false)
		enterShowAndChangeMode()
	}

	/// Berechnung-Tab oben rechts
	/// → hier: Create-Flow für Instrumente
	func switchToCalculation() {
		endEditSessionForNavigation(keepSelection: false)
		navigation.workspaceMode = .instrumentCalculation
		navigation.isLandingVisible = false
	}

	// MARK: - Draft

	func resetDraftInstrument() {
		draft.resetDraft()
		selectedInstrumentID = nil
		recalcDraftName()
	}

	func updateDraft(_ mutate: (inout Instrument) -> Void) {
		var copy = draft.draftInstrument
		mutate(&copy)
		copy.name = list.instrumentListTitle(for: copy)
		draft.draftInstrument = copy
	}

	private func recalcDraftName() {
		let title = list.instrumentListTitle(for: draft.draftInstrument)
		draft.draftInstrument.name = title
	}

	var draftNeedsisin: Bool {
		draft.draftNeedsisin
	}

	var draftNeedsRatio: Bool {
		draft.draftNeedsRatio
	}

	var draftSubgroups: [Subgroup] {
		draft.draftSubgroups
	}

	var isCurrentDraftValid: Bool {
		draft.isDraftValid(draft.draftInstrument)
	}

	func sanitizedDecimalInput(old: String, new: String) -> String {
		draft.sanitizedDecimalInput(old: old, new: new)
	}

	// MARK: - Create-Flow Edit-Unterstützung

	var isEditingExistingInstrument: Bool {
		draft.isEditingExistingInstrument
	}

	func startEditing(step: InstrumentDraftController.InstrumentCreationStep) {
		if isEditingExistingInstrument && !draft.allowedEditSteps.contains(step) {
			return
		}
		navigation.workspaceMode = .instrumentsCreate
		draft.editingReturnStep = draft.creationStep
		draft.creationStep = step
	}

	func finishEditingStepIfNeeded() {
		if isEditingExistingInstrument {
			if let idx = draft.allowedEditStepOrder.firstIndex(of: draft.creationStep) {
				let nextIndex = draft.allowedEditStepOrder.index(after: idx)
				if nextIndex < draft.allowedEditStepOrder.endIndex {
					draft.creationStep = draft.allowedEditStepOrder[nextIndex]
				} else {
					draft.creationStep = .done
				}
			} else {
				draft.creationStep = draftNeedsisin ? .isin : .basispreis
			}
			return
		}
		if let back = draft.editingReturnStep {
			draft.creationStep = back
			draft.editingReturnStep = nil
		}
	}

	func ensureAllowedEditStepIfNeeded() {
		guard isEditingExistingInstrument else { return }
		if draft.creationStep == .done {
			return
		}
		if !draft.allowedEditSteps.contains(draft.creationStep) {
			draft.creationStep = draftNeedsisin ? .isin : .basispreis
		}
	}

	func advanceDraftOrReturn(default next: InstrumentDraftController.InstrumentCreationStep) {
		if isEditingExistingInstrument {
			finishEditingStepIfNeeded()
		} else {
			draft.creationStep = next
		}
	}

	func cancelEditIfNeeded() {
		if isEditingExistingInstrument {
			discardEditSession()
		}
	}

	func enterEditModeForSelectedInstrument() {
		guard let sel = selectedInstrument else { return }
		draft.draftInstrument = sel
		draft.editingTargetID = sel.id
		navigation.workspaceMode = .instrumentsCreate
		navigation.isLandingVisible = false
		draft.editingReturnStep = nil
		draft.creationStep = draftNeedsisin ? .isin : .basispreis
	}

	func commitEditSession() {
		guard let targetID = draft.editingTargetID,
			  let original = instruments.first(where: { $0.id == targetID }) else {
			return
		}
		var updated = original
		updated.isin = draft.draftInstrument.isin
		updated.basispreis = draft.draftInstrument.basispreis
		updated.aufgeld = draft.draftInstrument.aufgeld
		updated.bezugsverhaeltnis = draft.draftInstrument.bezugsverhaeltnis
		updated.isFavorite = draft.draftInstrument.isFavorite
		updated.lastModified = Date()
		instrumentStore.update(updated)
		lastSavedInstrumentID = updated.id
		persistLastSavedInstrumentID(updated.id)

		draft.editingTargetID = nil
		draft.editingReturnStep = nil
		navigation.workspaceMode = .instrumentsShowAndChange
		draft.creationStep = .assetClass
		resetDraftInstrument()
		selectedInstrumentID = targetID
		navigation.isLandingVisible = false
	}

	func discardEditSession() {
		let targetID = draft.editingTargetID
		draft.editingTargetID = nil
		draft.editingReturnStep = nil
		navigation.workspaceMode = .instrumentsShowAndChange
		draft.creationStep = .assetClass
		resetDraftInstrument()
		if let targetID {
			selectedInstrumentID = targetID
		}
		navigation.isLandingVisible = false
	}

	private func endEditSessionForNavigation(keepSelection: Bool) {
		guard isEditingExistingInstrument else { return }
		let targetID = draft.editingTargetID
		draft.editingTargetID = nil
		draft.editingReturnStep = nil
		resetDraftInstrument()
		if keepSelection, let targetID {
			selectedInstrumentID = targetID
		}
	}

	private func persistLastSavedInstrumentID(_ id: UUID?) {
		if let id {
			UserDefaults.standard.set(id.uuidString, forKey: Self.lastSavedInstrumentIDKey)
		} else {
			UserDefaults.standard.removeObject(forKey: Self.lastSavedInstrumentIDKey)
		}
	}

	private func mostRecentlyModifiedInstrument() -> Instrument? {
		instruments.max { lhs, rhs in
			let l = lhs.lastModified ?? .distantPast
			let r = rhs.lastModified ?? .distantPast
			return l < r
		}
	}

	// MARK: - Public API für Instruments (rohe Daten)

	var instruments: [Instrument] {
		instrumentStore.allInstruments()
	}

	@discardableResult
	func addInstrument(_ instrument: Instrument) -> UUID {
		var inst = instrument
		inst.lastModified = Date()
		let id = instrumentStore.add(inst)

		lastSavedInstrumentID = id
		persistLastSavedInstrumentID(id)
		selectedInstrumentID = id

		return id
	}

	func updateInstrument(_ instrument: Instrument) {
		var inst = instrument
		inst.lastModified = Date()
		instrumentStore.update(inst)

		lastSavedInstrumentID = instrument.id
		persistLastSavedInstrumentID(instrument.id)
	}

	func deleteInstrument(_ instrument: Instrument) {
		instrumentStore.delete(instrument)
		lastShownInstrumentID = nil
		if lastSavedInstrumentID == instrument.id {
			let recent = mostRecentlyModifiedInstrument()
			lastSavedInstrumentID = recent?.id
			persistLastSavedInstrumentID(recent?.id)
		}
	}

	func enterCreateMode() {
		enterCreateMode(selectLastSaved: true)
	}

	private func enterCreateMode(selectLastSaved: Bool) {
		endEditSessionForNavigation(keepSelection: false)
		navigation.workspaceMode = .instrumentsCreate
		navigation.isLandingVisible = false
		resetDraftInstrument()

		if selectLastSaved, let id = lastSavedInstrumentID {
			selectedInstrumentID = id
		}
	}

	func enterShowAndChangeMode() {
		navigation.isLandingVisible = false

		if let recent = mostRecentlyModifiedInstrument() {
			selectedInstrumentID = recent.id
			if lastSavedInstrumentID == nil
				|| !instruments.contains(where: { $0.id == lastSavedInstrumentID }) {
				lastSavedInstrumentID = recent.id
				persistLastSavedInstrumentID(recent.id)
			}
		} else if let first = instruments.first {
			selectedInstrumentID = first.id
		}

		navigation.workspaceMode = .instrumentsShowAndChange
	}

	func startCreateFlow() {
		enterCreateMode()
	}

	func startEditFlow() {
		enterEditModeForSelectedInstrument()
	}

	func toggleGlobalCollapse() {
		collapse.setGlobalCollapsed(!collapse.isGlobalCollapsed)
	}

	func prepareDeleteSelectedInstrument() -> Instrument? {
		selectedInstrument
	}

	func confirmDelete(_ instrument: Instrument) {
		deleteInstrument(instrument)
	}

	// MARK: - Auswahl

	func selectInstrument(_ instrument: Instrument?) {
		selectedInstrumentID = instrument?.id
		if let id = instrument?.id {
			lastShownInstrumentID = id
		}
	}

	var selectedInstrument: Instrument? {
		guard let id = selectedInstrumentID else { return nil }
		return instruments.first(where: { $0.id == id })
	}

	// MARK: - Import

	func handleImportButtonTap() {
		switch draft.importState {
			case .idle:
				draft.importState = .awaitingClipboard
			case .awaitingClipboard:
				let clipped = readClipboardText().trimmingCharacters(in: .whitespacesAndNewlines)
				guard !clipped.isEmpty else {
					draft.importState = .idle
					return
				}
				draft.importedRawText = clipped
				draft.importState = .readyToImport
			case .readyToImport:
				applyBasicsImport(raw: draft.importedRawText)
				draft.importedRawText = ""
				draft.importState = .idle
		}
	}

	func applyBasicsImport(raw: String) {
		let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return }

		let basics = BasicsImportParser.parse(raw: trimmed)
		updateDraft { draft in
			self.draft.applyBasicsImport(basics, to: &draft)
		}

		draft.creationStep = .favorite
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

extension AppStateEngine {

	/// Debug-Ausgabe für den Abschluss des Create-Wizards
	func debugPrintDoneStepState(
		file: StaticString = #fileID,
		function: StaticString = #function,
		line: UInt = #line
	) {
		print("──────── DONE STEP DEBUG ────────")
		print("Timestamp:", Date())
		print("Source  :", "\(file) • \(function) #\(line)")
		print("creationStep:", draft.creationStep)
		print("draftInstrument:")
		print(draft.draftInstrument)
		print("instrumentStore.instruments.count:", instrumentStore.instruments.count)
		print("──────── END DONE STEP DEBUG ────────")
	}
}

	// MARK: - Instrument-Create-Flow Abschluss

extension AppStateEngine {

	func doneStep() {
		debugPrintDoneStepState()

		let newInstrument = draft.draftInstrument
		let newID = addInstrument(newInstrument)

		selectedInstrumentID = newID

		draft.creationStep = .done
		navigation.workspaceMode = .instrumentsShowAndChange
		navigation.isLandingVisible = false
	}
}
