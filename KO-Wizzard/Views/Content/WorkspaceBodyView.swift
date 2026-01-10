//
//  WorkspaceBodyView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 23.11.25.


import SwiftUI

struct WorkspaceBodyView: View {

	@EnvironmentObject var appState: AppStateEngine

	var body: some View {
		VStack(spacing: 0) {
			HStack(spacing: 0) {

					// Sidebar links
				SidebarView()
					.frame(width: 300)

					// Content rechts
				ContentRouterView()
			}
			footer
		}
	}

	private var footer: some View {
		HStack {
			Text("Wizard – \(appState.instrumentStore.instrumentCount) Assets geladen")
			Spacer()
			Text("Modus: \(modeLabel)")
		}
		.font(.custom("Menlo", size: 11))
		.foregroundColor(.white)
		.padding(.horizontal, 12)
		.frame(height: 26)
		.background(
			LinearGradient(
				colors: [Color.blue.opacity(0.55), Color.blue.opacity(0.9)],
				startPoint: .top,
				endPoint: .bottom
			)
		)
	}

	private var modeLabel: String {
		switch appState.workspaceMode {
			case .instrumentsCreate:
				return "Asset anlegen"
			case .instrumentsShowAndChange:
				return "Asset Ansicht"
			case .instrumentCalculation:
				return "Berechnen"
		}
	}
}
