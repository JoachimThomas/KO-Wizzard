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

				ForEach(appState.groupedInstruments, id: \.assetClass) { group in
					let assetClass = group.assetClass
					let instruments = group.instruments

						// komplette Gruppe pro AssetClass
					VStack(alignment: .leading, spacing: 4) {

							// AssetClass-Header
						Button {
							appState.toggleAssetClass(assetClass)
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

								Image(systemName: appState.isAssetClassCollapsed(assetClass)
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
						if !appState.isAssetClassCollapsed(assetClass) {

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

								if !subgroupName.trimmingCharacters(in: .whitespaces).isEmpty {
									Text(subgroupName)
										.font(.custom("Menlo", size: 12))
										.foregroundColor(Color.black.opacity(0.75))
										.padding(.horizontal, 16)
										.padding(.top, 4)
								}

								let longs  = inSub.filter { $0.direction == .long }
								let shorts = inSub.filter { $0.direction == .short }

									// LONG-Block
								if !longs.isEmpty {
									Text("Long")
										.font(.custom("Menlo", size: 11).weight(.medium))
										.foregroundColor(Color.black.opacity(0.65))
										.padding(.horizontal, 18)
										.padding(.top, 4)

									ForEach(longs) { instrument in
										SidebarRow(
											instrument: instrument,
											isSelected: instrument.id == appState.selectedInstrumentID
										)
										.environmentObject(appState)
									}
								}

									// SHORT-Block
								if !shorts.isEmpty {
									Text("Short")
										.font(.custom("Menlo", size: 11).weight(.medium))
										.foregroundColor(Color.black.opacity(0.65))
										.padding(.horizontal, 18)
										.padding(.top, 6)

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

				Spacer(minLength: 12)
			}
			.padding(.vertical, 8)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.scrollIndicators(.never)
		.background(.white)
	}
}
