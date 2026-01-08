//
//  ReportsView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 19.11.25.
//
import SwiftUI

	/// Hauptansicht für Auswertungen.
	/// Später:
	/// - Zeitraum-Filter (Woche, Monat, Jahr, custom)
	/// - KPIs: Anzahl Trades, Trefferquote, Gesamt-P&L
	/// - Liste der Trades
	/// - CSV-Export
struct ReportsView: View {

	@EnvironmentObject var appState: AppStateEngine

	var body: some View {
		VStack(alignment: .leading, spacing: 24) {

			Text("Auswertungen")
				.font(.largeTitle)
				.bold()

			Text("Hier erscheinen später die Auswertungen deiner Trades nach Zeitraum (Woche/Monat/Jahr) und Export als CSV.")
				.font(.body)
				.foregroundColor(.secondary)

			Divider()

			ReportView() // Unterkomponente (Detail-Bereich)

			Spacer()
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}
