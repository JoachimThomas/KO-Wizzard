	//
	//  InstrumentCalcView.swift
	//  KO-Wizzard
	//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct InstrumentCalcView: View {

	@EnvironmentObject var appState: AppStateEngine
	@Environment(\.appTheme) private var theme

	let instrument: Instrument?
	private let mode: NavigationController.WorkspaceMode = .instrumentCalculation
	@State private var showUnderlyingInput: Bool = false
	@State private var showCertificateInput: Bool = false
	@State private var underlyingValue: String = "—"
	@State private var certificateValue: String = "—"
	@State private var lastCopiedLabel: String?

	var body: some View {
		VStack(alignment: .leading, spacing: theme.metrics.spacingLarge) {
			titleCard("Asset-Kursberechnungen")

			if let instrument = instrument {
				mainCard(for: instrument)
			} else {
				emptyState
			}

			Spacer(minLength: 0)
		}
		.font(theme.fonts.body)
		.sheet(isPresented: $showUnderlyingInput) {
			ValueInputSheet(
				title: "Underlying eingeben",
				message: "Kurs des Underlyings",
				kind: .numeric,
				initialValue: "",
				onCommit: { raw in
					showUnderlyingInput = false
					applyUnderlyingInput(raw)
				},
				onCancel: {
					showUnderlyingInput = false
				}
			)
		}
		.sheet(isPresented: $showCertificateInput) {
			ValueInputSheet(
				title: "Zertifikatspreis eingeben",
				message: "Preis des Zertifikats",
				kind: .numeric,
				initialValue: "",
				onCommit: { raw in
					showCertificateInput = false
					applyCertificateInput(raw)
				},
				onCancel: {
					showCertificateInput = false
				}
			)
		}
	}

	private func titleCard(_ title: String) -> some View {
		Text(title)
			.font(theme.fonts.headline)
			.fontWeight(.bold)
			.contentEmphasis()
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.horizontal, theme.metrics.paddingLarge)
			.frame(height: theme.metrics.sidebarSearchHeight)
			.workspaceGradientBackground(cornerRadius: theme.metrics.cardCornerRadius)
			.padding(.top, theme.metrics.sidebarSearchPaddingTop)
	}

	// MARK: - Detail-Card

	@ViewBuilder
	private func detailContent(for i: Instrument) -> some View {
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
	}

		// MARK: - Calculation Card

	@ViewBuilder
	private func calculationContent() -> some View {
		VStack(alignment: .leading, spacing: 10) {
			calculationRow(
				label: "Underlying",
				value: underlyingValue,
				icon: "arrow.down.left"
			) {
				showUnderlyingInput = true
			}
			Divider()
			calculationRow(
				label: "Zertifikat",
				value: certificateValue,
				icon: "arrow.up.right"
			) {
				showCertificateInput = true
			}
		}
	}

	private func mainCard(for instrument: Instrument) -> some View {
		VStack(alignment: .leading, spacing: theme.metrics.spacingLarge) {
			detailContent(for: instrument)
			Divider()
			calculationContent()
		}
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

	private func calculationRow(
		label: String,
		value: String,
		icon: String,
		action: @escaping () -> Void
	) -> some View {
		HStack {
			Text(label)
				.foregroundColor(theme.colors.textSecondary)
				.frame(width: 150, alignment: .leading)
			Text(value)
				.fontWeight(.medium)
				.contentEmphasis(.identifier)
			if value != "—" {
				Button {
					copyToClipboard(value)
					lastCopiedLabel = label
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
						if lastCopiedLabel == label {
							lastCopiedLabel = nil
						}
					}
				} label: {
					Image(systemName: "doc.on.doc")
						.imageScale(.small)
						.foregroundColor(lastCopiedLabel == label
							? theme.colors.successGreen
							: theme.colors.textSecondary
						)
				}
				.buttonStyle(.plain)
				.help("In Zwischenablage kopieren")
			}
			Spacer()
			Button(action: action) {
				Image(systemName: icon)
					.imageScale(.small)
			}
			.buttonStyle(.plain)
		}
	}
	
	private func copyToClipboard(_ value: String) {
#if os(iOS)
		UIPasteboard.general.string = value
#elseif os(macOS)
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		pasteboard.setString(value, forType: .string)
#endif
	}

	private func applyUnderlyingInput(_ raw: String) {
		guard let instrument = instrument,
			  let underlying = Instrument.parseNumber(raw) else {
			underlyingValue = "—"
			certificateValue = "—"
			return
		}

		underlyingValue = raw

		let result = InstrumentPricingEngine.priceFromUnderlying(
			instrument: instrument,
			underlyingPrice: underlying
		)

		if let value = result.value {
			certificateValue = Instrument.compact(value)
		} else {
			certificateValue = "—"
		}
	}

	private func applyCertificateInput(_ raw: String) {
		guard let instrument = instrument,
			  let certificate = Instrument.parseNumber(raw) else {
			certificateValue = "—"
			underlyingValue = "—"
			return
		}

		certificateValue = raw

		let result = InstrumentPricingEngine.underlyingFromPrice(
			instrument: instrument,
			certificatePrice: certificate
		)

		if let value = result.value {
			underlyingValue = Instrument.compact(value)
		} else {
			underlyingValue = "—"
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
