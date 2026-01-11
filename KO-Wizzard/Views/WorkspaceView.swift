	//
	//  WorkspaceView.swift
	//  KO-Wizzard
	//

import SwiftUI

struct WorkspaceView: View {

	@EnvironmentObject var appState: AppStateEngine
	@State private var workspaceSize: CGSize = .zero

	var body: some View {
		VStack(spacing: 0) {

				// Oben: Toolbar über gesamte Breite
			WorkspaceToolbarView()
				.environmentObject(appState)
				.frame(height: 48)
				.padding(.top, 0)

			Divider()

				// Darunter: Sidebar links + Contentbereich rechts
			WorkspaceBodyView()
				.environmentObject(appState)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.coordinateSpace(name: "workspace")
		.background(
			GeometryReader { proxy in
				Color.clear
					.preference(key: WorkspaceSizePreferenceKey.self, value: proxy.size)
			}
			.allowsHitTesting(false)
		)
		.onPreferenceChange(WorkspaceSizePreferenceKey.self) { newValue in
			workspaceSize = newValue
		}
		.environment(\.workspaceSize, workspaceSize)
	}
}
