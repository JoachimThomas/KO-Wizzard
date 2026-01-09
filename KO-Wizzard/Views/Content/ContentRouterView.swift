//
//  ContentRouterView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 23.11.25.


import SwiftUI

struct ContentRouterView: View {

	@EnvironmentObject var appState: AppStateEngine

	var body: some View {
		switch appState.workspaceMode {

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

			case .instrumentsTrade:
				TradeContentView()
					.environmentObject(appState)

			case .reports:
				ReportsView()
					.environmentObject(appState)
		}
	}
}
