	//
	//  InstrumentDetailView.swift
	//  KO-Wizzard
	//

import SwiftUI

struct InstrumentDetailView: View {

	@EnvironmentObject var appState: AppStateEngine

	let mode: AppStateEngine.WorkspaceMode
	let instrument: Instrument?

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {

			Text(headerTitle)
				.font(.headline)
				.padding(.bottom, 4)

			if let instrument = instrument {
				detailCard(for: instrument)
			} else {
				emptyState
			}

			Spacer(minLength: 0)
		}
		.padding()
	}

		// MARK: - Header

	private var headerTitle: String {
		switch mode {
			case .instrumentsCreate:
				return "Instrument – Vorschau"
			case .instrumentsShowAndChange:
				return "Instrument – Details"
			case .instrumentCalculation:
				return "Instrument – Berechnung"
		}
	}

		// MARK: - Detail-Card

	@ViewBuilder
	private func detailCard(for i: Instrument) -> some View {
		VStack(alignment: .leading, spacing: 10) {

				// Name nur Anzeige, nicht direkt editierbar
			staticRow("Name", i.name)
			Divider()

			editableRow(
				"Assetklasse",
				i.assetClass.displayName.isEmpty ? "—" : i.assetClass.displayName,
				step: .assetClass
			)
			editableRow(
				"Subgroup",
				i.subgroup?.displayName ?? "—",
				step: .subgroup
			)

			editableRow(
				"Emittent",
				i.emittent.displayName.isEmpty ? "—" : i.emittent.displayName,
				step: .emittent
			)
			editableRow(
				"Richtung",
				i.direction.displayName.isEmpty ? "—" : i.direction.displayName,
				step: .direction
			)

			Divider()

			editableRow("Isin", i.isin.isEmpty ? "—" : i.isin, step: .isin)
			editableRow("Basispreis", i.basispreis.isEmpty ? "—" : i.basispreis, step: .basispreis)
			editableRow("Bezugsverhältnis",
						i.bezugsverhaeltnis.isEmpty ? "—" : i.bezugsverhaeltnis,
						step: .bezugsverhaeltnis)
			editableRow("Aufgeld",
						i.aufgeld.isEmpty ? "—" : i.aufgeld,
						step: .aufgeld)

			Divider()

			editableRow("Favorit",
						i.isFavorite ? "★ Ja" : "– Nein",
						step: .favorite)
		}
		.padding()
		.background(Color.secondary.opacity(0.08))
		.cornerRadius(14)
	}

		// MARK: - Rows

	private func staticRow(_ label: String, _ value: String) -> some View {
		HStack {
			Text(label)
				.foregroundColor(.secondary)
				.frame(width: 150, alignment: .leading)
			Text(value)
				.fontWeight(.medium)
			Spacer()
		}
	}

	private func editableRow(
		_ label: String,
		_ value: String,
		step: AppStateEngine.InstrumentCreationStep
	) -> some View {
		HStack {
			Text(label)
				.foregroundColor(mode == .instrumentsCreate ? .blue : .secondary)
				.frame(width: 150, alignment: .leading)
			Text(value)
				.fontWeight(.medium)
			Spacer()
		}
		.contentShape(Rectangle())
		.onTapGesture {
			guard mode == .instrumentsCreate else { return }
			appState.startEditing(step: step)
		}
	}

		// MARK: - Empty State

	private var emptyState: some View {
		VStack(spacing: 8) {
			Text("Kein Instrument ausgewählt")
				.foregroundColor(.secondary)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}
