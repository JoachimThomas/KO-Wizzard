	//
	//  InstrumentCalcView.swift
	//  KO-Wizzard
	//

import SwiftUI

struct InstrumentCalcView: View {

	@EnvironmentObject var appState: AppStateEngine

	let instrument: Instrument?
	private let mode: AppStateEngine.WorkspaceMode = .instrumentCalculation
	@State private var showUnderlyingInput: Bool = false
	@State private var showCertificateInput: Bool = false
	@State private var underlyingValue: String = "—"
	@State private var certificateValue: String = "—"

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {

			Text(headerTitle)
				.font(.headline)
				.padding(.bottom, 4)

			if let instrument = instrument {
				detailCard(for: instrument)
				calculationCard()
			} else {
				emptyState
			}

			Spacer(minLength: 0)
		}
		.padding()
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

		// MARK: - Calculation Card

	@ViewBuilder
	private func calculationCard() -> some View {
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

	private func calculationRow(
		label: String,
		value: String,
		icon: String,
		action: @escaping () -> Void
	) -> some View {
		HStack {
			Text(label)
				.foregroundColor(.secondary)
				.frame(width: 150, alignment: .leading)
			Text(value)
				.fontWeight(.medium)
			Spacer()
			Button(action: action) {
				Image(systemName: icon)
					.imageScale(.small)
			}
			.buttonStyle(.plain)
		}
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
				.foregroundColor(.secondary)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}
