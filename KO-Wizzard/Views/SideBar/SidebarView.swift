	//
	//  SidebarView.swift
	//  KO-Wizzard
	//
	//  Created by Joachim Thomas on 19.11.25.
	//
	//
	//  SidebarView.swift
	//  KO-Wizard
	//

import SwiftUI

struct SidebarView: View {

	@EnvironmentObject var appState: AppStateEngine
	@FocusState private var searchIsFocused: Bool

	var body: some View {
		VStack(spacing: 0) {

				// Header ("Instrumente (n)")
			// Suchfeld
			searchField

				// eigentliche Liste
			SidebarListArea()
				.environmentObject(appState)
		}
		.frame(width: 280)
		.frame(maxHeight: .infinity, alignment: .top)
		.workspaceGradientBackground()
	}

		// MARK: - Suche

	private var searchField: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 6)
				.fill(Color.white.opacity(0.08))

			HStack(spacing: 6) {
				Image(systemName: "magnifyingglass")
					.font(.system(size: 11))
					.opacity(0.7)

				TextField("Suche (Subgroup, isin, Richtung …)", text: $appState.list.searchText)
					.textFieldStyle(.plain)
					.foregroundColor(.primary)
					.font(.custom("Menlo", size: 12))
					.focused($searchIsFocused)

				if !appState.list.searchText.isEmpty {
					Button {
						appState.list.searchText = ""
					} label: {
						Image(systemName: "xmark.circle.fill")
							.font(.system(size: 11))
							.opacity(0.6)
					}
					.buttonStyle(.plain)
				}
			}
			.padding(.horizontal, 8)
		}
		.frame(height: 30)
		.padding(.horizontal, 8)
		.padding(.top, 8)
		.padding(.bottom, 6)
	}
}
