//
//  SidebarRow.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 19.11.25.
//

import SwiftUI

struct SidebarRow: View {

	@EnvironmentObject var appState: AppStateEngine
	@Environment(\.appTheme) private var theme

	let instrument: Instrument
	let isSelected: Bool

	var body: some View {
		Button {
			appState.selectInstrument(instrument)
		} label: {
			HStack(spacing: 8) {

				Circle()
					.fill(instrument.isFavorite
						? theme.colors.sidebarIndicatorFavorite
						: theme.colors.sidebarIndicatorActive)
					.frame(width: 6, height: 6)
					.overlay(
						Group {
							if instrument.id == appState.lastSavedInstrumentID {
								Circle()
									.fill(theme.colors.sidebarIndicatorRecent)
									.frame(width: 8, height: 8)
							}
						}
					)

				Text(displayTitle)
					.font(.custom("Menlo", size: 14).weight(isSelected ? .semibold : .regular))
					.foregroundColor(theme.colors.sidebarText)
					.lineLimit(1)

				Spacer(minLength: 0)
			}
			.padding(.horizontal, theme.metrics.sidebarRowPaddingH)
			.padding(.vertical, theme.metrics.sidebarRowPaddingV)
			.background(
				Group {
					if isSelected {
						RoundedRectangle(cornerRadius: theme.metrics.sidebarRowCornerRadius)
							.fill(theme.colors.sidebarSelection)
					} else {
						Color.clear
					}
				}
			)
		}
		.buttonStyle(.plain)
	}

	private var displayTitle: String {
		let title = appState.list.instrumentListTitle(for: instrument)
		return title.isEmpty ? instrument.name : title
	}
}
