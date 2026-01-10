	//
	//  WorkspaceToolbarView.swift
	//  KO-Wizzard
	//

import SwiftUI

	// Oberer Toolbar-Bereich für den Workspace
	// Links: Listensteuerung (Alle, Favoriten, Collapse, Neu)
	// Rechts: Tabs (Instrument, Berechnung, Trade, Report)
struct WorkspaceToolbarView: View {

	@EnvironmentObject var appState: AppStateEngine
    @State private var showDeleteAlert = false
    @State private var instrumentToDelete: Instrument?

	
	var body: some View {
		HStack(spacing: 16) {

				// LINKER BEREICH ≈ Sidebar-Breite
			HStack(spacing: 8) {

					//Alle Ansicht
				Button {
					appState.showFavoritesOnly = false
				} label: {
					Image(systemName: "chart.line.uptrend.xyaxis")
						.imageScale(.large)
				}
				.help("Alle Instrumente anzeigen")

					// Favoriten-Ansicht
				Button {
					appState.showFavoritesOnly = true
				} label: {
					Image(systemName: appState.showFavoritesOnly ? "star.fill" : "star")
						.imageScale(.large)
				}
				.help("Nur Favoriten anzeigen")
				// Verlauf, die letzten 10
				Button {
					appState.showFavoritesOnly = false
					appState.showRecentOnly.toggle()
				} label: {
					Image(systemName: "clock")
						.imageScale(.large)
				}
				.help("Verlauf der letzten 10 Listeneinträge anzeigen")

					// Assetklassen Zuklappen / Aufklappen
				Button {
					appState.setGlobalCollapsed(!appState.isGlobalCollapsed)
				} label: {
					Image(systemName: appState.isGlobalCollapsed ? "book.closed" : "book")
						.imageScale(.large)
				}
				.help(appState.isGlobalCollapsed ? "Alle Assetklassen expandieren" : "Alle Assetklassen einklappen")

					// Neues Instrument
				Button {
					appState.enterCreateMode()
				} label: {
					Image(systemName: "document.badge.plus")
						.imageScale(.large)
				}
				.help("Neues Instrument anlegen")

					// Instrument ändern
				Button {
					appState.enterCreateMode()
				} label: {
					Image(systemName:"slider.horizontal.2.arrow.trianglehead.counterclockwise")
						.imageScale(.large)
				}
				.help("Instrument ändern")

					// Instrument löschen
				Button {

                    let inst: Instrument = appState.selectedInstrument!
                    instrumentToDelete = inst
                    showDeleteAlert = true
				} label: {
					Image(systemName: "document.on.trash")
						.imageScale(.large)
				}
				.help("Instrument löschen")

			}

			.frame(width: 300, alignment: .leading)
					.padding(.leading, -20)


				Spacer()

					// RECHTER BEREICH – Tabs: Instrument / Berechnung / Trade / Report
				HStack(spacing: 8) {
					topTabButton(
						title: "Instrument",
						isActive: appState.workspaceMode == .instrumentsShowAndChange
						|| appState.workspaceMode == .instrumentsCreate
					) {
						appState.switchToInstruments()
					}

					topTabButton(
						title: "Berechnung",
						isActive: appState.workspaceMode == .instrumentCalculation
					) {
						appState.selectedTab = .instruments
						appState.workspaceMode = .instrumentCalculation
						appState.isLandingVisible = false
					}

					topTabButton(
						title: "Trade",
						isActive: appState.workspaceMode == .instrumentsTrade
					) {
						appState.switchToTrades()
					}

					topTabButton(
						title: "Report",
						isActive: appState.workspaceMode == .reports
					) {
						appState.switchToReports()
					}
				}
            }
            .alert("Achtung!", isPresented: $showDeleteAlert, presenting: instrumentToDelete) { inst in
                Button("Löschen", role: .destructive) {
                    appState.deleteInstrument(inst)

                }
                Button("Abbrechen", role: .cancel) {}
            } message: { inst in
                Text("Soll das Instrument '\(inst.name)' wirklich gelöscht werden?")
            }
            .padding(.horizontal, 16)
			.padding(.vertical, 8)
		}
	}

	private func topTabButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
		Button(action: action) {
			Text(title)
				.font(.subheadline)
				.fontWeight(.semibold)
				.padding(.horizontal, 12)
				.padding(.vertical, 6)
				.background(
					RoundedRectangle(cornerRadius: 8)
						.fill(isActive ? Color.accentColor.opacity(0.2) : Color.clear)
				)
		}
		.buttonStyle(.bordered)
	}
