//
//  InstrumentCreateView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 23.11.25.
//

import SwiftUI

struct InstrumentCreateView: View {

	@EnvironmentObject var appState: AppStateEngine
	@Environment(\.appTheme) private var theme

	var body: some View {
		VStack(alignment: .leading, spacing: theme.metrics.spacingLarge) {
			titleCard("Asset-Datenerfassung")
			VStack(alignment: .leading, spacing: theme.metrics.spacingLarge) {
				InstrumentCreateFlowView(showsCard: false, usesInternalPadding: false)
					.environmentObject(appState)
				Divider()
				InstrumentDetailView(
					mode: .instrumentsCreate,
					instrument: appState.draft.draftInstrument,
					showsCard: false,
					usesInternalPadding: false
				)
				.environmentObject(appState)
			}
			.padding(theme.metrics.paddingLarge)
			.workspaceGradientBackground(cornerRadius: theme.metrics.cardCornerRadius)
		}
	}

	private func titleCard(_ title: String) -> some View {
		Text(title)
			.font(theme.fonts.headline)
			.fontWeight(.bold)
			.contentEmphasis()
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(theme.metrics.paddingLarge)
			.workspaceGradientBackground(cornerRadius: theme.metrics.cardCornerRadius)
	}
}
