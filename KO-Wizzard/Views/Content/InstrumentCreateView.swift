//
//  InstrumentCreateView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 23.11.25.


import SwiftUI

struct InstrumentCreateView: View {

	@EnvironmentObject var appState: AppStateEngine

	var body: some View {
		GeometryReader { geo in
			VStack(spacing: 12) {

					// 1. Flow oben
				InstrumentCreateFlowView()
					.environmentObject(appState)
					.frame(maxWidth: .infinity)
					.frame(height: geo.size.height * 0.38)
					.padding(.horizontal)
					.padding(.top)

					// 2. Anzeige-Card unten
				InstrumentDetailView(
					mode: .instrumentsCreate,
					instrument: appState.draftInstrument
				)
				.environmentObject(appState)
				.frame(maxWidth: .infinity)
				.frame(height: geo.size.height * 0.58)
				.padding(.horizontal)
				.padding(.bottom)

				Spacer(minLength: 0)
			}
		}
	}
}
