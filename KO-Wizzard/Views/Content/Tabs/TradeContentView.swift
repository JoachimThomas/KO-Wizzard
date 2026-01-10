//
//  TradeContentView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 23.11.25.
//
//
//  TradeContentView.swift
//  KO-Wizzard
//

import SwiftUI

struct TradeContentView: View {

	@EnvironmentObject var appState: AppStateEngine

	@State private var broker: String = ""
	@State private var entry: String = ""
	@State private var exit: String = ""

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {

			Text("Trade erfassen")
				.font(.menlo(textStyle: .headline))

			Divider()

				// Instrument-Auswahl-Anzeige
			if let i = appState.selectedInstrument {
				instrumentInfo(i)
			} else {
				Text("Kein Instrument gewählt.")
					.foregroundColor(.secondary)
			}

			Divider()

				// Eingabefelder (Platzhalter)
			TextField("Broker", text: $broker)
				.textFieldStyle(.roundedBorder)

			TextField("Entry", text: $entry)
				.textFieldStyle(.roundedBorder)

			TextField("Exit", text: $exit)
				.textFieldStyle(.roundedBorder)

			HStack {
				Text("P&L:")
				Spacer()
			Text(pnlString)
					.font(.menlo(textStyle: .headline))
			}

			Spacer()
		}
		.padding()
		.font(.menlo(textStyle: .body))
	}

		// MARK: - Instrument Info

	@ViewBuilder
	private func instrumentInfo(_ i: Instrument) -> some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(i.name)
				.font(.menlo(textStyle: .headline))
			Text("Isin: \(i.isin)")
				.foregroundColor(.secondary)
		}
	}

		// MARK: - Mini P&L (Platzhalter)

	private var pnlString: String {
		guard let e = Double(entry.replacingOccurrences(of: ",", with: ".")),
			  let x = Double(exit.replacingOccurrences(of: ",", with: ".")) else {
			return "—"
		}
		let pnl = x - e
		return String(format: "%.2f", pnl)
	}
}
