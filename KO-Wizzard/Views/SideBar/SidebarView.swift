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
			header

				// Suchfeld
			searchField

				// eigentliche Liste
			SidebarListArea()
				.environmentObject(appState)
		}
		.frame(width: 280)
		.frame(maxHeight: .infinity, alignment: .top)
		.background(.white)
	}

		// MARK: - Header

	private var header: some View {
		HStack(spacing: 8) {
			Text("Instrumente")
				.font(.system(size: 13, weight: .semibold))

			Text("(\(appState.filteredInstruments.count))")
				.font(.system(size: 11))
				.opacity(0.65)

			Spacer()
		}
		.padding(.horizontal, 10)
		.padding(.vertical, 6)
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

				TextField("Suche (Subgroup, isin, Richtung …)", text: $appState.searchText)
					.textFieldStyle(.plain)
					.foregroundColor(.primary)
					.font(.system(size: 11))
					.focused($searchIsFocused)

				if !appState.searchText.isEmpty {
					Button {
						appState.searchText = ""
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
		.padding(.bottom, 6)
	}
}
