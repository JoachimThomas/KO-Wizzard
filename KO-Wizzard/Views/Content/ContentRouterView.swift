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
					InstrumentDetailView(
						mode: .instrumentsShowAndChange,
						instrument: appState.selectedInstrument
					)
				case .instrumentCalculation:
					InstrumentCalcView(
						instrument: appState.selectedInstrument
					)

			}
		}
		.font(theme.fonts.body)
		.padding(.horizontal, theme.metrics.contentPaddingH)
	}
}
