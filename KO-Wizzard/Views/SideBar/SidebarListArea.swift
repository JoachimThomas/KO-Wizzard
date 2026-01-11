//
//  SidebarListArea.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 19.11.25.
//

import SwiftUI

struct SidebarListArea: View {

	@EnvironmentObject var appState: AppStateEngine

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 10) {

				ForEach(appState.list.groupedInstruments, id: \.assetClass) { group in
					let assetClass = group.assetClass
					let instruments = group.instruments

						// komplette Gruppe pro AssetClass
					VStack(alignment: .leading, spacing: 4) {

							// AssetClass-Header
						Button {
							appState.collapse.toggleAssetClass(assetClass)
						} label: {
							HStack(spacing: 8) {
									// Punkt zeigt: hier lebt was
								Circle()
									.fill(instruments.isEmpty
										  ? Color.gray.opacity(0.3)
										  : Color.green.opacity(0.9))
									.frame(width: 6, height: 6)

								Text(assetClass.displayName)
									.font(.custom("Menlo", size: 13).weight(.semibold))
									.foregroundColor(Color.black.opacity(0.88))

								Spacer()

								Image(systemName: appState.collapse.isAssetClassCollapsed(assetClass)
									  ? "chevron.right"
									  : "chevron.down")
								.font(.system(size: 12, weight: .bold))
								.foregroundColor(Color.black.opacity(0.65))
							}
							.padding(.horizontal, 10)
							.padding(.vertical, 6)
						}
						.buttonStyle(.plain)

							// Inhalte: nur wenn NICHT eingeklappt
						if !appState.collapse.isAssetClassCollapsed(assetClass) {

								// nach Subgroup / Underlying gruppieren
							let subgroupNames: [String] = Array(
								Set(
									instruments.map { ins in
										let name = ins.subgroup?.displayName ?? ins.underlyingName
										return name.trimmingCharacters(in: .whitespaces)
									}
								)
							)
								.sorted { $0.lowercased() < $1.lowercased() }

							ForEach(subgroupNames, id: \.self) { subgroupName in
								let inSub = instruments.filter { ins in
									let name = (ins.subgroup?.displayName ?? ins.underlyingName)
										.trimmingCharacters(in: .whitespaces)
									return name == subgroupName
								}

								let trimmedSubgroup = subgroupName.trimmingCharacters(in: .whitespaces)

								if !trimmedSubgroup.isEmpty {
									Button {
										appState.collapse.toggleSubgroup(
											assetClass: assetClass,
											subgroup: trimmedSubgroup
										)
									} label: {
										HStack(spacing: 6) {
											Text(trimmedSubgroup)
												.font(.custom("Menlo", size: 12))
												.foregroundColor(Color.black.opacity(0.75))

											Spacer()

											Image(systemName: appState.collapse.isSubgroupCollapsed(
												assetClass: assetClass,
												subgroup: trimmedSubgroup
											) ? "chevron.right" : "chevron.down")
											.font(.system(size: 10, weight: .bold))
											.foregroundColor(Color.black.opacity(0.55))
										}
										.padding(.horizontal, 16)
										.padding(.top, 4)
									}
									.buttonStyle(.plain)
								}

								let isSubgroupCollapsed = !trimmedSubgroup.isEmpty
									&& appState.collapse.isSubgroupCollapsed(assetClass: assetClass, subgroup: trimmedSubgroup)

								if !isSubgroupCollapsed {
									let longs  = inSub.filter { $0.direction == .long }
									let shorts = inSub.filter { $0.direction == .short }

									// LONG-Block
									if !longs.isEmpty {
									Button {
										appState.collapse.toggleDirection(
											assetClass: assetClass,
											subgroup: trimmedSubgroup,
											direction: .long
										)
									} label: {
										HStack(spacing: 6) {
											Text("Long")
												.font(.custom("Menlo", size: 11).weight(.medium))
												.foregroundColor(Color.black.opacity(0.65))

											Spacer()

										Image(systemName: appState.collapse.isDirectionCollapsed(
											assetClass: assetClass,
											subgroup: trimmedSubgroup,
											direction: .long
										) ? "chevron.right" : "chevron.down")
											.font(.system(size: 10, weight: .bold))
											.foregroundColor(Color.black.opacity(0.55))
										}
										.padding(.horizontal, 18)
										.padding(.top, 4)
									}
									.buttonStyle(.plain)

									if !appState.collapse.isDirectionCollapsed(
										assetClass: assetClass,
										subgroup: trimmedSubgroup,
										direction: .long
									) {
										ForEach(longs) { instrument in
											SidebarRow(
												instrument: instrument,
												isSelected: instrument.id == appState.selectedInstrumentID
											)
											.environmentObject(appState)
										}
									}
								}

									// SHORT-Block
									if !shorts.isEmpty {
									Button {
										appState.collapse.toggleDirection(
											assetClass: assetClass,
											subgroup: trimmedSubgroup,
											direction: .short
										)
									} label: {
										HStack(spacing: 6) {
											Text("Short")
												.font(.custom("Menlo", size: 11).weight(.medium))
												.foregroundColor(Color.black.opacity(0.65))

											Spacer()

										Image(systemName: appState.collapse.isDirectionCollapsed(
											assetClass: assetClass,
											subgroup: trimmedSubgroup,
											direction: .short
										) ? "chevron.right" : "chevron.down")
											.font(.system(size: 10, weight: .bold))
											.foregroundColor(Color.black.opacity(0.55))
										}
										.padding(.horizontal, 18)
										.padding(.top, 6)
									}
									.buttonStyle(.plain)

									if !appState.collapse.isDirectionCollapsed(
										assetClass: assetClass,
										subgroup: trimmedSubgroup,
										direction: .short
									) {
										ForEach(shorts) { instrument in
											SidebarRow(
												instrument: instrument,
												isSelected: instrument.id == appState.selectedInstrumentID
											)
											.environmentObject(appState)
										}
									}
									}
								}
							}
						}
					}
				}

				Spacer(minLength: 12)
			}
			.padding(.vertical, 8)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.scrollIndicators(.never)
		.background(Color.clear)
	}
}
