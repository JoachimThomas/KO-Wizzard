//
//  InstrumentListController.swift
//  KO-Wizzard
//

import Foundation
import Combine

final class InstrumentListController: ObservableObject {

	@Published var showFavoritesOnly: Bool = false
	@Published var showRecentOnly: Bool = false
	@Published var searchText: String = ""

	private let instrumentStore: InstrumentStore
	private var cancellables = Set<AnyCancellable>()

	init(instrumentStore: InstrumentStore) {
		self.instrumentStore = instrumentStore
		instrumentStore.objectWillChange
			.sink { [weak self] _ in
				self?.objectWillChange.send()
			}
			.store(in: &cancellables)
	}

	var instruments: [Instrument] {
		instrumentStore.allInstruments()
	}

	private func normalizedSearchString(_ s: String) -> String {
		s
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.lowercased()
			.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
	}

	private func instrumentSort(lhs: Instrument, rhs: Instrument) -> Bool {
		let acL = lhs.assetClass.displayName
		let acR = rhs.assetClass.displayName
		if acL != acR { return acL < acR }

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

	func instrumentListTitle(for instrument: Instrument) -> String {
		let subgroupName = instrument.subgroup?.displayName ?? ""
		let subclass = subgroupName.isEmpty ? instrument.underlyingName : subgroupName

		let dir = instrument.direction.displayName
		let bp = Instrument.compact(instrument.basispreisValue)

		return [subclass, dir, bp]
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			.filter { !$0.isEmpty }
			.joined(separator: " · ")
	}

	var filteredInstruments: [Instrument] {
		var result = instruments

		if showRecentOnly {
			let recent = result
				.filter { $0.lastModified != nil }
				.sorted { ($0.lastModified!) > ($1.lastModified!) }

			result = Array(recent.prefix(10))
		}

		if showFavoritesOnly {
			result = result.filter { $0.isFavorite }
		}

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

				return parts.allSatisfy { token in
					haystack.contains(token)
				}
			}
		}

		result.sort(by: instrumentSort(lhs:rhs:))
		return result
	}

	var groupedInstruments: [(assetClass: AssetClass, instruments: [Instrument])] {
		let base = filteredInstruments
		let grouped = Dictionary(grouping: base, by: { $0.assetClass })

		let sortedKeys = grouped.keys.sorted { $0.displayName < $1.displayName }

		return sortedKeys.map { key in
			let items = (grouped[key] ?? []).sorted(by: instrumentSort(lhs:rhs:))
			return (assetClass: key, instruments: items)
		}
	}

	struct SidebarSection {
		let assetClass: AssetClass
		let subgroups: [SidebarSubgroupSection]
	}

	struct SidebarSubgroupSection {
		let name: String
		let longs: [Instrument]
		let shorts: [Instrument]
	}

	func groupedSidebarSections() -> [SidebarSection] {
		groupedInstruments.map { group in
			let subgroupMap: [String: [Instrument]] = Dictionary(grouping: group.instruments) { ins in
				(ins.subgroup?.displayName ?? ins.underlyingName)
					.trimmingCharacters(in: .whitespacesAndNewlines)
			}

			let subgroupNames = subgroupMap.keys.sorted { $0.lowercased() < $1.lowercased() }
			let subgroups = subgroupNames.map { name in
				let inSub = subgroupMap[name] ?? []
				let longs = inSub.filter { $0.direction == .long }
				let shorts = inSub.filter { $0.direction == .short }
				return SidebarSubgroupSection(name: name, longs: longs, shorts: shorts)
			}

			return SidebarSection(assetClass: group.assetClass, subgroups: subgroups)
		}
	}

	func showAllInstruments() {
		showFavoritesOnly = false
		showRecentOnly = false
	}

	func toggleFavoritesOnly() {
		showFavoritesOnly.toggle()
	}

	func toggleRecentOnly() {
		if showRecentOnly {
			showRecentOnly = false
		} else {
			showFavoritesOnly = false
			showRecentOnly = true
		}
	}
}
