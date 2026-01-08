	//
	//  WorkspaceView.swift
	//  KO-Wizzard
	//

import SwiftUI

struct WorkspaceView: View {

	@EnvironmentObject var appState: AppStateEngine

	var body: some View {
		VStack(spacing: 0) {

				// Oben: Toolbar über gesamte Breite
			WorkspaceToolbarView()
				.environmentObject(appState)
				.frame(height: 48)
				.padding(.horizontal)
				.padding(.top, 4)

			Divider()

				// Darunter: Sidebar links + Contentbereich rechts
			WorkspaceBodyView()
				.environmentObject(appState)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}
