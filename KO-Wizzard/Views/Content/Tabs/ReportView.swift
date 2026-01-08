//
//  ReportView.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 19.11.25.
//
import SwiftUI

	/// Wird innerhalb von ReportsView angezeigt.
	/// Zeigt später KPIs, Zeitraum-Auswahl, Trade-Liste, Export-Button etc.
struct ReportView: View {

	@EnvironmentObject var appState: AppStateEngine

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {

			Text("Report Details")
				.font(.title2)
				.bold()

			Text("Hier werden später die Kennzahlen, Filter und Listen für deine Trade-Auswertungen angezeigt.")
				.font(.body)
				.foregroundColor(.secondary)

			Spacer()
		}
	}
}

#Preview {
	ReportsView()
		.environmentObject(AppStateEngine())
}
