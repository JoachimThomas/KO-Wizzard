//
//  ContentRouterView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 23.11.25.


import SwiftUI

struct ContentRouterView: View {

	@EnvironmentObject var appState: AppStateEngine
	@Environment(\.appTheme) private var theme

	var body: some View {
		Group {
			switch appState.navigation.workspaceMode {

			case .instrumentsCreate:
				InstrumentCreateView()

			case .instrumentsShowAndChange:
				VStack(alignment: .leading, spacing: theme.metrics.spacingLarge) {
					titleCard("Asset-Details")
					InstrumentDetailView(
						mode: .instrumentsShowAndChange,
						instrument: appState.selectedInstrument
					)
				}
				case .instrumentCalculation:
					InstrumentCalcView(
						instrument: appState.selectedInstrument
					)

			}
		}
		.font(theme.fonts.body)
		.padding(.horizontal, theme.metrics.contentPaddingH)
	}

	private func titleCard(_ title: String) -> some View {
		Text(title)
			.font(theme.fonts.headline)
			.fontWeight(.bold)
			.contentEmphasis()
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.horizontal, theme.metrics.paddingLarge)
			.frame(height: theme.metrics.sidebarSearchHeight)
			.workspaceGradientBackground(cornerRadius: theme.metrics.cardCornerRadius)
			.padding(.top, theme.metrics.sidebarSearchPaddingTop)
	}
}
