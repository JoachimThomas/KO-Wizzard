//
//  SidebarCollapseController.swift
//  KO-Wizzard
//

import Foundation
import Combine

final class SidebarCollapseController: ObservableObject {

	@Published var isGlobalCollapsed: Bool = false
	@Published private var collapsedAssetClasses: Set<AssetClass> = []
	@Published private var collapsedDirections: Set<DirectionCollapseKey> = []
	@Published private var collapsedSubgroups: Set<String> = []

	private let instrumentsProvider: () -> [Instrument]

	init(instrumentsProvider: @escaping () -> [Instrument]) {
		self.instrumentsProvider = instrumentsProvider
	}

	func isAssetClassCollapsed(_ assetClass: AssetClass) -> Bool {
		collapsedAssetClasses.contains(assetClass)
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

	func setInitialCollapseState(selectedInstrument: Instrument?) {
		let assetClasses = currentAssetClasses()
		guard let selected = selectedInstrument else {
			collapsedAssetClasses = assetClasses
			collapsedSubgroups.removeAll()
			collapsedDirections.removeAll()
			recomputeGlobalCollapsedState()
			return
		}

		collapsedAssetClasses = assetClasses
		collapsedAssetClasses.remove(selected.assetClass)

		let subgroupName = (selected.subgroup?.displayName ?? selected.underlyingName)
			.trimmingCharacters(in: .whitespacesAndNewlines)
		let allSubgroupKeys = Set(instrumentsProvider().map { instrument in
			let name = (instrument.subgroup?.displayName ?? instrument.underlyingName)
				.trimmingCharacters(in: .whitespacesAndNewlines)
			return subgroupKey(assetClass: instrument.assetClass, subgroup: name)
		})
		collapsedSubgroups = allSubgroupKeys
		if !subgroupName.isEmpty {
			collapsedSubgroups.remove(subgroupKey(assetClass: selected.assetClass, subgroup: subgroupName))
		}

		let allDirectionKeys = currentDirectionKeys()
		collapsedDirections = allDirectionKeys
		if !subgroupName.isEmpty {
			let selectedKey = DirectionCollapseKey(
				assetClass: selected.assetClass,
				subgroup: subgroupName,
				direction: selected.direction
			)
			collapsedDirections.remove(selectedKey)
		}

		recomputeGlobalCollapsedState()
	}

	private func subgroupKey(assetClass: AssetClass, subgroup: String) -> String {
		let trimmed = subgroup.trimmingCharacters(in: .whitespacesAndNewlines)
		return "\(assetClass.rawValue)|\(trimmed)"
	}

	private func currentAssetClasses() -> Set<AssetClass> {
		Set(instrumentsProvider().map { $0.assetClass })
	}

	private func currentDirectionKeys() -> Set<DirectionCollapseKey> {
		var keys: Set<DirectionCollapseKey> = []
		for instrument in instrumentsProvider() {
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
}

private struct DirectionCollapseKey: Hashable {
	let assetClass: AssetClass
	let subgroup: String
	let direction: Direction
}
