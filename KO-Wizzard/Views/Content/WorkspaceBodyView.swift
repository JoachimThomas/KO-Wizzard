//
//  WorkspaceBodyView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 23.11.25.


import SwiftUI

struct WorkspaceBodyView: View {

	@EnvironmentObject var appState: AppStateEngine
	@Environment(\.appTheme) private var theme

	var body: some View {
		VStack(spacing: 0) {
			HStack(spacing: 0) {

				// Sidebar links
				SidebarView()
					.frame(width: theme.metrics.sidebarWidth)

					// Content rechts
				ContentRouterView()
			}
			footer
		}
	}

       
	private var footer: some View {
		let isEditing = appState.draft.isEditingExistingInstrument

		return HStack {
			Text("Wizard – \(appState.instrumentStore.instrumentCount) Assets geladen")
				.foregroundColor(theme.colors.footerText)
			Spacer()
			Text(isEditing ? "Modus: Asset-Änderung" : "Modus: \(modeLabel)")
				.foregroundColor(isEditing ? theme.colors.alertRed : theme.colors.footerText)
		}
		.font(theme.fonts.footerSmall)
		.padding(.horizontal, theme.metrics.paddingMedium)
		.frame(height: 26)
        .background(
            ZStack {
                    // 1. Die native macOS Material-Basis (Vibrancy-Effekt)
                Rectangle()
                    .fill(.ultraThinMaterial)

                    // 2. Der spezifische, invertierte Farbverlauf als Overlay
				theme.gradients.footer(theme.colors)
					.blendMode(.multiply) // Sorgt für organische Verschmelzung
            }
			.allowsHitTesting(false)
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
