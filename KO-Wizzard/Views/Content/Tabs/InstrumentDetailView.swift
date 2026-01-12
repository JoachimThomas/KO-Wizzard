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
	let showsCard: Bool
	let usesInternalPadding: Bool

	init(
		mode: NavigationController.WorkspaceMode,
		instrument: Instrument?,
		showsCard: Bool = true,
		usesInternalPadding: Bool = true
	) {
		self.mode = mode
		self.instrument = instrument
		self.showsCard = showsCard
		self.usesInternalPadding = usesInternalPadding
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			if let instrument = instrument {
				detailCard(for: instrument)
			} else {
				emptyState
			}
			Spacer(minLength: 0)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.font(theme.fonts.body)
	}

		// MARK: - Detail-Card

	@ViewBuilder
	private func detailCard(for i: Instrument) -> some View {
		let contentPadding = usesInternalPadding ? theme.metrics.paddingLarge : 0
		let content = VStack(alignment: .leading, spacing: 10) {

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
		.padding(contentPadding)

		if showsCard {
			content
				.workspaceGradientBackground(cornerRadius: theme.metrics.cardCornerRadius)
		} else {
			content
		}
	}

		// MARK: - Rows

	private func staticRow(
		_ label: String,
		_ value: String,
		emphasis: ContentEmphasisKind = .standard
	) -> some View {
		HStack {
			Text(label)
				.foregroundColor(theme.colors.textSecondary)
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
				.foregroundColor(mode == .instrumentsCreate ? theme.colors.actionBlue : theme.colors.textSecondary)
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
				.foregroundColor(theme.colors.textSecondary)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}
