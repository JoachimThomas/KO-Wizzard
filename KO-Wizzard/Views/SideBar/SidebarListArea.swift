//
//  SidebarListArea.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 19.11.25.
//

import SwiftUI

struct SidebarListArea: View {

	@EnvironmentObject var appState: AppStateEngine
	@Environment(\.appTheme) private var theme

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: theme.metrics.sidebarListSpacing) {

				ForEach(appState.list.groupedInstruments, id: \.assetClass) { group in
					let assetClass = group.assetClass
					let instruments = group.instruments

						// komplette Gruppe pro AssetClass
					VStack(alignment: .leading, spacing: theme.metrics.sidebarGroupSpacing) {

							// AssetClass-Header
						Button {
							appState.collapse.toggleAssetClass(assetClass)
						} label: {
							HStack(spacing: 8) {
									// Punkt zeigt: hier lebt was
								Circle()
									.fill(instruments.isEmpty
										  ? theme.colors.sidebarIndicatorEmpty
										  : theme.colors.sidebarIndicatorActive)
									.frame(width: 6, height: 6)

								Text(assetClass.displayName)
									.font(theme.fonts.sidebarHeader)
									.foregroundColor(theme.colors.sidebarHeaderText)

								Spacer()

								Image(systemName: appState.collapse.isAssetClassCollapsed(assetClass)
									  ? "chevron.right"
									  : "chevron.down")
								.font(theme.fonts.sidebarChevron)
								.foregroundColor(theme.colors.sidebarChevron)
							}
							.padding(.horizontal, theme.metrics.sidebarGroupPaddingH)
							.padding(.vertical, theme.metrics.sidebarGroupPaddingV)
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
												.font(theme.fonts.sidebarSubgroup)
												.foregroundColor(theme.colors.sidebarSubgroupText)

											Spacer()

											Image(systemName: appState.collapse.isSubgroupCollapsed(
												assetClass: assetClass,
												subgroup: trimmedSubgroup
											) ? "chevron.right" : "chevron.down")
											.font(theme.fonts.sidebarChevronSmall)
											.foregroundColor(theme.colors.sidebarChevronMuted)
										}
										.padding(.horizontal, theme.metrics.sidebarSubgroupPaddingH)
										.padding(.top, theme.metrics.sidebarSubgroupPaddingTop)
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
												.font(theme.fonts.sidebarDirection)
												.foregroundColor(theme.colors.sidebarDirectionText)

											Spacer()

										Image(systemName: appState.collapse.isDirectionCollapsed(
											assetClass: assetClass,
											subgroup: trimmedSubgroup,
											direction: .long
										) ? "chevron.right" : "chevron.down")
											.font(theme.fonts.sidebarChevronSmall)
											.foregroundColor(theme.colors.sidebarChevronMuted)
										}
										.padding(.horizontal, theme.metrics.sidebarDirectionPaddingH)
										.padding(.top, theme.metrics.sidebarDirectionPaddingTop)
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
												.font(theme.fonts.sidebarDirection)
												.foregroundColor(theme.colors.sidebarDirectionText)

											Spacer()

										Image(systemName: appState.collapse.isDirectionCollapsed(
											assetClass: assetClass,
											subgroup: trimmedSubgroup,
											direction: .short
										) ? "chevron.right" : "chevron.down")
											.font(theme.fonts.sidebarChevronSmall)
											.foregroundColor(theme.colors.sidebarChevronMuted)
										}
										.padding(.horizontal, theme.metrics.sidebarDirectionPaddingH)
										.padding(.top, theme.metrics.sidebarDirectionPaddingTopAlt)
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
			.padding(.vertical, theme.metrics.sidebarFooterPaddingV)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.scrollIndicators(.never)
		.background(Color.clear)
	}
}
