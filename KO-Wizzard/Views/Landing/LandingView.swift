//
//  LandingView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 19.11.25.
//
import SwiftUI

struct LandingView: View {

	@EnvironmentObject var appState: AppStateEngine

	var body: some View {
		VStack(spacing: 32) {

				// App-Icon
			Image("Chart")        // <- ggf. Name im Asset Catalog anpassen
				.resizable()
				.scaledToFit()
				.frame(width: 160, height: 160)
				.cornerRadius(32)
				.shadow(radius: 12)
				.padding(.top, 40)

				// Buttons
			VStack(spacing: 20) {

				landingButton("Instrument anlegen") {
					appState.enterCreateMode()
				}

				landingButton("Instrument anzeigen") {
					appState.enterShowAndChangeMode()
				}

				landingButton("Trade erfassen") {
					appState.startTradeCreation()
				}

				landingButton("Auswertung") {
					appState.showReports()
				}
			}
			.padding(.horizontal, 24)

			Spacer()
		}
	}

	private func landingButton(_ title: String, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Text(title)
				.font(.title2)
				.fontWeight(.semibold)
				.frame(maxWidth: .infinity)
				.padding()
				.foregroundColor(.white)
				.background(Color.blue)
				.cornerRadius(12)
		}
	}
}

#Preview {
	LandingView()
		.environmentObject(AppStateEngine())
}
