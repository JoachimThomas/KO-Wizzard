import Foundation
import SwiftUI
import Combine

	/// Zentrale Engine der KO-Wizard App
	/// - Hält globalen State (Landing, Workspace-Modi)
	/// - Beinhaltet Stores (Instrumente, später Trades)
	/// - Views greifen ausschließlich über diese Engine zu

final class AppStateEngine: ObservableObject {

		// MARK: - (Legacy) Tabs – aktuell nur noch logisch

	enum RootTab: Hashable {
		case instruments
	}

	@Published var selectedTab: RootTab = .instruments

	func selectTab(_ tab: RootTab) {
		selectedTab = tab
	}

		// MARK: - Workspace-Modus (Hauptzustände im Workspace)

	enum WorkspaceMode: Hashable {
		case instrumentsCreate          // "create Instrument"
		case instrumentsShowAndChange   // "show & change Instrument"
		case instrumentCalculation      // Calculations
	}

		/// Steuert, welcher Inhalt im Workspace angezeigt wird
	@Published var workspaceMode: WorkspaceMode = .instrumentsShowAndChange

		// MARK: - Landing / Navigation

		/// Steuert, ob die LandingPage sichtbar ist
	@Published var isLandingVisible: Bool = true

		// MARK: - Instrument-Erstellung (Draft)

		/// Entwurf für ein neues Instrument im Create-Flow
	@Published var draftInstrument: Instrument = .empty()

		/// Aktueller Schritt der Benutzerführung (kann später genutzt werden, aktuell nur vorbereitet)
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

	@Published var creationStep: InstrumentCreationStep = .assetClass
	let allowedEditSteps: Set<InstrumentCreationStep> = [
		.isin,
		.basispreis,
		.bezugsverhaeltnis,
		.aufgeld,
		.favorite
	]
	private let allowedEditStepOrder: [InstrumentCreationStep] = [
		.isin,
		.basispreis,
		.bezugsverhaeltnis,
		.aufgeld,
		.favorite
	]

	// Landing-Button: "Instrument anlegen"
	func startInstrumentCreation() {
		endEditSessionForNavigation(keepSelection: false)
		resetDraftInstrument()
		selectedTab = .instruments
		workspaceMode = .instrumentsCreate
		isLandingVisible = false
	}

	// Landing-Button: "Instrument anzeigen"
	func showInstrumentList() {
		endEditSessionForNavigation(keepSelection: false)
		enterShowAndChangeMode()
	}

	 func resetDraftInstrument() {
		draftInstrument = .empty()
		creationStep = .assetClass
		selectedInstrumentID = nil
		recalcDraftName()
	}

		// MARK: - Top-Toolbar-Tabs (rechts: Instrument / Berechnung / Trade / Report)

	/// Instrument-Tab oben rechts
	func switchToInstruments() {
		endEditSessionForNavigation(keepSelection: false)
		enterShowAndChangeMode()
	}

	/// Berechnung-Tab oben rechts
	/// → hier: Create-Flow für Instrumente
	func switchToCalculation() {
		endEditSessionForNavigation(keepSelection: false)
		selectedTab = .instruments
		workspaceMode = .instrumentCalculation
		isLandingVisible = false
	}

		// MARK: - Stores

	let instrumentStore: InstrumentStore
		// später:
		// let tradeStore: TradeStore

		// MARK: - Instrument-Listen-State

		/// Nur Favoriten anzeigen oder alle
	@Published var showFavoritesOnly: Bool = false

		/// Nur die letzten 10 gespeicherten Instrumente anzeigen (Verlauf)
	@Published var showRecentOnly: Bool = false

		/// Suchtext: Isin, Subgroup, Direction, Kombis wie "dax short"
	@Published var searchText: String = ""

		/// Globaler Collapse-Status für die Liste (Toolbar steuert das später)
	@Published var isGlobalCollapsed: Bool = false

	/// Einzelne Asset-Klassen einklappbar
	@Published private var collapsedAssetClasses: Set<AssetClass> = []
	@Published private var collapsedDirections: Set<DirectionCollapseKey> = []
	@Published private var collapsedSubgroups: Set<String> = []

	private struct DirectionCollapseKey: Hashable {
		let assetClass: AssetClass
		let subgroup: String
		let direction: Direction
	}

	private func subgroupKey(assetClass: AssetClass, subgroup: String) -> String {
		let trimmed = subgroup.trimmingCharacters(in: .whitespacesAndNewlines)
		return "\(assetClass.rawValue)|\(trimmed)"
	}

		/// Aktuell ausgewähltes Instrument (per ID)
	@Published var selectedInstrumentID: UUID? = nil

	/// Zuletzt gespeichertes Instrument (Neu oder geändert)
	@Published var lastSavedInstrumentID: UUID? = nil
	private static let lastSavedInstrumentIDKey = "lastSavedInstrumentID"

		/// Zuletzt im Show-&-Change-Modus angezeigtes Instrument
	@Published var lastShownInstrumentID: UUID? = nil

		// MARK: - Init

	init(instrumentStore: InstrumentStore = InstrumentStore()) {
		self.instrumentStore = instrumentStore
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
	}

		// Irgendwo bei den Published Properties
	@Published var editingReturnStep: InstrumentCreationStep? = nil
	@Published var editingTargetID: UUID? = nil

	var isEditingExistingInstrument: Bool {
		editingTargetID != nil
	}

		// MARK: - Create-Flow Edit-Unterstützung

	func startEditing(step: InstrumentCreationStep) {
		if isEditingExistingInstrument && !allowedEditSteps.contains(step) {
			return
		}
			// Nur im Create-Mode sinnvoll
		workspaceMode = .instrumentsCreate
		editingReturnStep = creationStep
		creationStep = step
	}

	func finishEditingStepIfNeeded() {
		if isEditingExistingInstrument {
			if let idx = allowedEditStepOrder.firstIndex(of: creationStep) {
				let nextIndex = allowedEditStepOrder.index(after: idx)
				if nextIndex < allowedEditStepOrder.endIndex {
					creationStep = allowedEditStepOrder[nextIndex]
				} else {
					creationStep = .done
				}
			} else {
				creationStep = draftNeedsisin ? .isin : .basispreis
			}
			return
		}
		if let back = editingReturnStep {
			creationStep = back
			editingReturnStep = nil
		}
	}

	func ensureAllowedEditStepIfNeeded() {
		guard isEditingExistingInstrument else { return }
		if creationStep == .done {
			return
		}
		if !allowedEditSteps.contains(creationStep) {
			creationStep = draftNeedsisin ? .isin : .basispreis
		}
	}

	func enterEditModeForSelectedInstrument() {
		guard let sel = selectedInstrument else { return }
		draftInstrument = sel
		editingTargetID = sel.id
		workspaceMode = .instrumentsCreate
		isLandingVisible = false
		editingReturnStep = nil
		creationStep = draftNeedsisin ? .isin : .basispreis
	}

	func commitEditSession() {
		guard let targetID = editingTargetID,
			  let original = instruments.first(where: { $0.id == targetID }) else {
			return
		}
		var updated = original
		updated.isin = draftInstrument.isin
		updated.basispreis = draftInstrument.basispreis
		updated.aufgeld = draftInstrument.aufgeld
		updated.bezugsverhaeltnis = draftInstrument.bezugsverhaeltnis
		updated.isFavorite = draftInstrument.isFavorite
		updated.lastModified = Date()
		instrumentStore.update(updated)
		lastSavedInstrumentID = updated.id
		persistLastSavedInstrumentID(updated.id)

		editingTargetID = nil
		editingReturnStep = nil
		selectedTab = .instruments
		workspaceMode = .instrumentsShowAndChange
		creationStep = .assetClass
		resetDraftInstrument()
		selectedInstrumentID = targetID
		isLandingVisible = false
	}

	func discardEditSession() {
		let targetID = editingTargetID
		editingTargetID = nil
		editingReturnStep = nil
		workspaceMode = .instrumentsShowAndChange
		creationStep = .assetClass
		resetDraftInstrument()
		if let targetID {
			selectedInstrumentID = targetID
		}
		isLandingVisible = false
	}

	private func endEditSessionForNavigation(keepSelection: Bool) {
		guard isEditingExistingInstrument else { return }
		let targetID = editingTargetID
		editingTargetID = nil
		editingReturnStep = nil
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

		/// Alle Instrumente aus dem Store
	var instruments: [Instrument] {
		instrumentStore.allInstruments()
	}

		/// Instrument hinzufügen
	@discardableResult
	func addInstrument(_ instrument: Instrument) -> UUID {
		var inst = instrument
		inst.lastModified = Date()        // Timestamp setzen
		let id = instrumentStore.add(inst)

			// NEU: letzte Speicherung merken
		lastSavedInstrumentID = id
		persistLastSavedInstrumentID(id)
		selectedInstrumentID = id         // optional: direkt auswählen

		return id
	}

		/// Instrument aktualisieren
	func updateInstrument(_ instrument: Instrument) {
		var inst = instrument
		inst.lastModified = Date()        // Timestamp setzen
		instrumentStore.update(inst)

			// NEU: letzte Speicherung merken
		lastSavedInstrumentID = instrument.id
		persistLastSavedInstrumentID(instrument.id)
	}

		/// Instrument löschen
	func deleteInstrument(_ instrument: Instrument) {
		instrumentStore.delete(instrument)
		lastShownInstrumentID = nil
		if lastSavedInstrumentID == instrument.id {
			let recent = mostRecentlyModifiedInstrument()
			lastSavedInstrumentID = recent?.id
			persistLastSavedInstrumentID(recent?.id)
		}
	}

		/// Create-Mode betreten:
		/// - Draft ggf. resetten
		/// - zuletzt gespeichertes Instrument in der Liste markiert lassen
	func enterCreateMode() {
		endEditSessionForNavigation(keepSelection: false)
		selectedTab = .instruments
		workspaceMode = .instrumentsCreate
		isLandingVisible = false
		resetDraftInstrument()

		if let id = lastSavedInstrumentID {
			selectedInstrumentID = id
		}
	}

		/// Show-&-Change-Modus betreten:
		/// - wenn vorhanden: zuletzt angezeigtes Instrument markieren
		/// - sonst: zuletzt gespeichertes
		/// - sonst: erstes vorhandenes
	func enterShowAndChangeMode() {
		selectedTab = .instruments
		isLandingVisible = false

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

		workspaceMode = .instrumentsShowAndChange
	}
		// MARK: - Draft-Manipulation (Create-Flow)

		/// Allgemeine Update-Funktion für den Draft, sorgt auch dafür,
		/// dass der Instrumentenname live neu berechnet wird.
	func updateDraft(_ mutate: (inout Instrument) -> Void) {
		var copy = draftInstrument
		mutate(&copy)
		draftInstrument = copy
		recalcDraftName()
	}

		/// Live-Instrumentname nach Subgroup / Direction / Basispreis
	private func recalcDraftName() {
		let title = instrumentListTitle(for: draftInstrument)
		draftInstrument.name = title
	}

		/// IG-Emittent → Isin & Bezugsverhältnis werden nicht benötigt
	var draftNeedsisin: Bool {
		draftInstrument.emittent != .igMarkets
	}

	var draftNeedsRatio: Bool {
		draftInstrument.emittent != .igMarkets
	}

		/// Zulässige Subgroups für die aktuell gewählte Assetklasse
	var draftSubgroups: [Subgroup] {
		AssetClass.subgroupsTyped(for: draftInstrument.assetClass)
	}

		/// Filtert numerische Eingaben:
		/// - Erlaubt nur 0–9, "," und "."
		/// - Wandelt "." → ","
		/// - Maximal ein Komma
		/// - Kein Start mit Komma
	func sanitizedDecimalInput(old: String, new: String) -> String {
			// Erst alle Punkte in Kommas verwandeln
		let replaced = new.replacingOccurrences(of: ".", with: ",")

			// Nur erlaubte Zeichen behalten
		let allowed = Set("0123456789,")
		let filtered = replaced.filter { allowed.contains($0) }

		var result = ""
		var commaSeen = false

		for ch in filtered {
			if ch == "," {
					// zweites Komma ignorieren
				if commaSeen { continue }
					// nicht mit Komma anfangen
				if result.isEmpty { continue }
				commaSeen = true
			}
			result.append(ch)
		}

		return result
	}

		// MARK: - Listenlogik: Filter, Suche, Sortierung, Gruppierung

		/// Normalisiert Strings für Suche (lowercase, trim, Mehrfachspaces weg)
	private func normalizedSearchString(_ s: String) -> String {
		s
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.lowercased()
			.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
	}

		/// Sortierung:
		/// AssetClass -> Subgroup -> Direction -> Instrumentname
	private func instrumentSort(lhs: Instrument, rhs: Instrument) -> Bool {
		let acL = lhs.assetClass.displayName
		let acR = rhs.assetClass.displayName
		if acL != acR { return acL < acR }

			// Subgroup-Enum: fallback auf "" bei nil
		let sgL = lhs.subgroup?.displayName.lowercased() ?? ""
		let sgR = rhs.subgroup?.displayName.lowercased() ?? ""
		if sgL != sgR { return sgL < sgR }

		let dirL = lhs.direction.displayName
		let dirR = rhs.direction.displayName
		if dirL != dirR { return dirL < dirR }

		let nameL = instrumentListTitle(for: lhs).lowercased()
		let nameR = instrumentListTitle(for: rhs).lowercased()
		return nameL < nameR
	}

		/// Name für die Listenanzeige:
		/// Subclass · Direction · Basispreis
	func instrumentListTitle(for instrument: Instrument) -> String {
			// 1) Subgroup oder UnderlyingName
		let subgroupName = instrument.subgroup?.displayName ?? ""
		let subclass = subgroupName.isEmpty
		? instrument.underlyingName
		: subgroupName

			// 2) Direction
		let dir = instrument.direction.displayName

			// 3) Basispreis kompakt
		let bp = Instrument.compact(instrument.basispreisValue)

			// 4) Bausteine säubern und zusammenfügen
		return [subclass, dir, bp]
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			.filter { !$0.isEmpty }
			.joined(separator: " · ")
	}

		/// Filtert und sortiert alle Instrumente gemäß:
		/// - Verlauf: die neuesten 10 (optional)
		/// - Favoritenfilter
		/// - Suche (ISIN, Subgroup, Direction, Kombis wie "dax short")
		/// - Sortierung: AssetClass -> Subgroup -> Direction -> Instrumentname
	var filteredInstruments: [Instrument] {
		var result = instruments

			// 1) Verlauf: nur Instrumente mit Timestamp, davon die 10 neuesten
		if showRecentOnly {
			let recent = result
				.filter { $0.lastModified != nil }
				.sorted { ($0.lastModified!) > ($1.lastModified!) }

			result = Array(recent.prefix(10))
		}

			// 2) Favoritenfilter
		if showFavoritesOnly {
			result = result.filter { $0.isFavorite }
		}

			// 3) Suche
		let query = normalizedSearchString(searchText)
		if !query.isEmpty {
			let parts = query.split(separator: " ").map { String($0) }

			result = result.filter { ins in
				let subgroupName = ins.subgroup?.displayName ?? ""

				let haystack = [
					subgroupName,
					ins.underlyingName,
					ins.direction.displayName,
					ins.isin,
					instrumentListTitle(for: ins)
				]
					.joined(separator: " ")
					.lowercased()

					// alle Suchbegriffe müssen vorkommen (UND-Verknüpfung)
				return parts.allSatisfy { token in
					haystack.contains(token)
				}
			}
		}

			// 4) Sortierung
		result.sort(by: instrumentSort(lhs:rhs:))
		return result
	}
		/// Gruppierung nach AssetClass (für sektionierte Liste)
		/// AssetKlasse -> [Instrumente]
	var groupedInstruments: [(assetClass: AssetClass, instruments: [Instrument])] {
		let base = filteredInstruments
		let grouped = Dictionary(grouping: base, by: { $0.assetClass })

		let sortedKeys = grouped.keys.sorted { $0.displayName < $1.displayName }

		return sortedKeys.map { key in
			let items = (grouped[key] ?? []).sorted(by: instrumentSort(lhs:rhs:))
			return (assetClass: key, instruments: items)
		}
	}

		// MARK: - Collapse-Steuerung

	func isAssetClassCollapsed(_ assetClass: AssetClass) -> Bool {
		return collapsedAssetClasses.contains(assetClass)
	}

	func toggleAssetClass(_ assetClass: AssetClass) {
		if collapsedAssetClasses.contains(assetClass) {
			collapsedAssetClasses.remove(assetClass)
		} else {
			collapsedAssetClasses.insert(assetClass)
		}
		recomputeGlobalCollapsedState()
	}

	func setGlobalCollapsed(_ flag: Bool) {
		if flag {
			collapsedAssetClasses = currentAssetClasses()
			collapsedDirections = currentDirectionKeys()
		} else {
			collapsedAssetClasses.removeAll()
			collapsedDirections.removeAll()
		}
		recomputeGlobalCollapsedState()
	}

	func isDirectionCollapsed(assetClass: AssetClass, subgroup: String, direction: Direction) -> Bool {
		if isAssetClassCollapsed(assetClass) {
			return true
		}
		let key = DirectionCollapseKey(
			assetClass: assetClass,
			subgroup: subgroup.trimmingCharacters(in: .whitespacesAndNewlines),
			direction: direction
		)
		return collapsedDirections.contains(key)
	}

	func toggleDirection(assetClass: AssetClass, subgroup: String, direction: Direction) {
		let key = DirectionCollapseKey(
			assetClass: assetClass,
			subgroup: subgroup.trimmingCharacters(in: .whitespacesAndNewlines),
			direction: direction
		)
		if collapsedDirections.contains(key) {
			collapsedDirections.remove(key)
		} else {
			collapsedDirections.insert(key)
		}
		recomputeGlobalCollapsedState()
	}

	func isSubgroupCollapsed(assetClass: AssetClass, subgroup: String) -> Bool {
		let key = subgroupKey(assetClass: assetClass, subgroup: subgroup)
		return collapsedSubgroups.contains(key)
	}

	func toggleSubgroup(assetClass: AssetClass, subgroup: String) {
		let key = subgroupKey(assetClass: assetClass, subgroup: subgroup)
		if collapsedSubgroups.contains(key) {
			collapsedSubgroups.remove(key)
		} else {
			collapsedSubgroups.insert(key)
		}
		recomputeGlobalCollapsedState()
	}

	private func currentAssetClasses() -> Set<AssetClass> {
		Set(filteredInstruments.map { $0.assetClass })
	}

	private func currentDirectionKeys() -> Set<DirectionCollapseKey> {
		var keys: Set<DirectionCollapseKey> = []
		for instrument in filteredInstruments {
			let subgroup = (instrument.subgroup?.displayName ?? instrument.underlyingName)
				.trimmingCharacters(in: .whitespacesAndNewlines)
			let key = DirectionCollapseKey(
				assetClass: instrument.assetClass,
				subgroup: subgroup,
				direction: instrument.direction
			)
			keys.insert(key)
		}
		return keys
	}

	private func recomputeGlobalCollapsedState() {
		let assetClasses = currentAssetClasses()
		if assetClasses.isEmpty {
			isGlobalCollapsed = true
			return
		}
		isGlobalCollapsed = assetClasses.isSubset(of: collapsedAssetClasses)
	}

		// MARK: - Auswahl

	func selectInstrument(_ instrument: Instrument?) {
		selectedInstrumentID = instrument?.id
		if let id = instrument?.id {
			lastShownInstrumentID = id     // immer merken, was zuletzt im Show-&-Change aktiv war
		}
	}

	var selectedInstrument: Instrument? {
		guard let id = selectedInstrumentID else { return nil }
		return instruments.first(where: { $0.id == id })
	}
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
		print("creationStep:", creationStep)
		print("draftInstrument:")
		print(draftInstrument)
		print("instrumentStore.instruments.count:", instrumentStore.instruments.count)
		print("──────── END DONE STEP DEBUG ────────")
	}
}
	// MARK: - Instrument-Create-Flow Abschluss

extension AppStateEngine {

	func doneStep() {
		debugPrintDoneStepState()

			// aktuellen Draft sichern
		let newInstrument = draftInstrument

			// im Store ablegen
		let newID = addInstrument(newInstrument)

			// Auswahl auf das neue Instrument setzen
		selectedInstrumentID = newID

			// Draft zurücksetzen & View in "zeigen/ändern"-Modus
		creationStep = .done
		workspaceMode = .instrumentsShowAndChange
		isLandingVisible = false
	}
}
