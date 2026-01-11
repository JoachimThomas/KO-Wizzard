//
//  InstrumentCreateView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 23.11.25.
//

import SwiftUI

struct InstrumentCreateView: View {

	@EnvironmentObject var appState: AppStateEngine

	var body: some View {
		VStack {
			InstrumentCreateFlowView()
				.environmentObject(appState)
			InstrumentDetailView(
				mode: .instrumentsCreate,
				instrument: appState.draft.draftInstrument
			)
			.environmentObject(appState)
		}
	}
}
