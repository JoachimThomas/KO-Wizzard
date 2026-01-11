//
//  SidebarRow.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 19.11.25.
//

import SwiftUI

struct SidebarRow: View {

	@EnvironmentObject var appState: AppStateEngine

	let instrument: Instrument
	let isSelected: Bool

	var body: some View {
		Button {
			appState.selectInstrument(instrument)
		} label: {
			HStack(spacing: 8) {

				Circle()
					.fill(instrument.isFavorite ? Color.yellow : Color.green)
					.frame(width: 6, height: 6)
					.overlay(
						Group {
							if instrument.id == appState.lastSavedInstrumentID {
								Circle()
									.fill(Color.red)
									.frame(width: 8, height: 8)
							}
						}
					)

				Text(displayTitle)
					.font(.custom("Menlo", size: 14).weight(isSelected ? .semibold : .regular))
					.foregroundColor(Color.black.opacity(0.88))
					.lineLimit(1)

				Spacer(minLength: 0)
			}
			.padding(.horizontal, 18)
			.padding(.vertical, 6)
			.background(
				Group {
					if isSelected {
						RoundedRectangle(cornerRadius: 6)
							.fill(SidebarStyle.selectedRowBackground)
					} else {
						Color.clear
					}
				}
			)
		}
		.buttonStyle(.plain)
	}

	private var displayTitle: String {
		let title = appState.list.instrumentListTitle(for: instrument)
		return title.isEmpty ? instrument.name : title
	}
}
