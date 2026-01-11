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

       
        // Stelle sicher, dass diese Definition in RootView oder einem gemeinsam genutzten Bereich existiert
    private let appBlue = Color(red: 0.0, green: 0.48, blue: 1.0)

	private var footer: some View {
		let isEditing = appState.draft.isEditingExistingInstrument

		return HStack {
			Text("Wizard – \(appState.instrumentStore.instrumentCount) Assets geladen")
				.foregroundColor(.white)
			Spacer()
			Text(isEditing ? "Modus: Asset-Änderung" : "Modus: \(modeLabel)")
				.foregroundColor(isEditing ? .red : .white)
		}
		.font(.custom("Menlo", size: 11))
		.padding(.horizontal, 12)
		.frame(height: 26)
        .background(
            ZStack {
                    // 1. Die native macOS Material-Basis (Vibrancy-Effekt)
                Rectangle()
                    .fill(.ultraThinMaterial)

                    // 2. Der spezifische, invertierte Farbverlauf als Overlay
                LinearGradient(
                    colors: [
                        appBlue.opacity(0.5),  // Oberer Rand des Footers (heller zur App-Mitte)
                        appBlue.opacity(0.8)   // Unterer Rand des Footers (dunkler zum Fensterrand)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blendMode(.multiply) // Sorgt für organische Verschmelzung
            }
        )
    }



	private var modeLabel: String {
		switch appState.navigation.workspaceMode {
			case .instrumentsCreate:
				return "Asset anlegen"
			case .instrumentsShowAndChange:
				return "Asset Ansicht"
			case .instrumentCalculation:
				return "Berechnen"
		}
	}
}
