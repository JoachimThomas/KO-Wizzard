	//
	//  InstrumentDetailView.swift
	//  KO-Wizzard
	//

import SwiftUI

struct InstrumentDetailView: View {

	@EnvironmentObject var appState: AppStateEngine
	@Environment(\.appTheme) private var theme

	let mode: NavigationController.WorkspaceMode
	let instrument: Instrument?

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {

			Text(headerTitle)
				.font(.menlo(textStyle: .headline))
				.fontWeight(.bold)
				.contentEmphasis()
				.padding(.bottom, 4)
				.padding(.leading, mode == .instrumentsCreate ? 20 : 0)

			if let instrument = instrument {
				detailCard(for: instrument)
			} else {
				emptyState
			}

		Spacer(minLength: 0)
	}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(.vertical, mode == .instrumentsShowAndChange ? 16 : 0)
		.font(.menlo(textStyle: .body))
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

			editableRow("Isin", i.isin.isEmpty ? "—" : i.isin, step: .isin, emphasis: .identifier)
			editableRow("Basispreis", i.basispreis.isEmpty ? "—" : i.basispreis, step: .basispreis, emphasis: .identifier)
			editableRow("Bezugsverhältnis",
						i.bezugsverhaeltnis.isEmpty ? "—" : i.bezugsverhaeltnis,
						step: .bezugsverhaeltnis,
						emphasis: .identifier)
			editableRow("Aufgeld",
						i.aufgeld.isEmpty ? "—" : i.aufgeld,
						step: .aufgeld,
						emphasis: .identifier)

			Divider()

			editableRow("Favorit",
						i.isFavorite ? "★ Ja" : "– Nein",
						step: .favorite)
		}
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.metrics.paddingLarge)
		.workspaceGradientBackground(cornerRadius: theme.metrics.cardCornerRadius)
	}

		// MARK: - Rows

	private func staticRow(
		_ label: String,
		_ value: String,
		emphasis: ContentEmphasisKind = .standard
	) -> some View {
		HStack {
			Text(label)
				.foregroundColor(.secondary)
				.frame(width: 150, alignment: .leading)
			Text(value)
				.fontWeight(.medium)
				.contentEmphasis(emphasis)
			Spacer()
		}
	}

	private func editableRow(
		_ label: String,
		_ value: String,
		step: InstrumentDraftController.InstrumentCreationStep,
		emphasis: ContentEmphasisKind = .standard
	) -> some View {
		HStack {
			Text(label)
				.foregroundColor(mode == .instrumentsCreate ? .blue : .secondary)
				.frame(width: 150, alignment: .leading)
			Text(value)
				.fontWeight(.medium)
				.contentEmphasis(emphasis)
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
