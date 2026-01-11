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
	@State private var isCreateHovered: Bool = false
	@State private var isShowHovered: Bool = false
	@State private var isCalcHovered: Bool = false
	@State private var isAllHovered: Bool = false
	@State private var isFavoritesHovered: Bool = false
	@State private var isRecentHovered: Bool = false
	@State private var isCollapseHovered: Bool = false
	@State private var isCreateHoveredLeft: Bool = false
	@State private var isEditHovered: Bool = false
	@State private var isDeleteHovered: Bool = false

	
	var body: some View {
		let sidebarWidth: CGFloat = 300

		HStack(spacing: 16) {

				// LINKER BEREICH ≈ Sidebar-Breite
			HStack(spacing: 8) {

					//Alle Ansicht
				Button {
					appState.list.showFavoritesOnly = false
					appState.list.showRecentOnly = false
				} label: {
					toolbarIcon(systemName: "chart.line.uptrend.xyaxis", isHovered: isAllHovered)
				}
				.buttonStyle(ToolbarIconStyle())
				.focusable(false)
				.focusEffectDisabled(true)
				.help("Alle Instrumente anzeigen")
				.onHover { hovering in
					isAllHovered = hovering
				}

				// Favoriten-Ansicht
				Button {
					appState.list.showFavoritesOnly.toggle()
				} label: {
					toolbarIcon(
						systemName: appState.list.showFavoritesOnly ? "star.fill" : "star",
						isHovered: isFavoritesHovered
					)
				}
				.buttonStyle(ToolbarIconStyle())
				.focusable(false)
				.focusEffectDisabled(true)
				.help("Nur Favoriten anzeigen")
				.onHover { hovering in
					isFavoritesHovered = hovering
				}
					// Verlauf, die letzten 10
				Button {
					if appState.list.showRecentOnly {
						appState.list.showRecentOnly = false
					} else {
						appState.list.showFavoritesOnly = false
						appState.list.showRecentOnly = true
					}
				} label: {
					toolbarIcon(systemName: "clock", isHovered: isRecentHovered)
				}
				.buttonStyle(ToolbarIconStyle())
				.focusable(false)
				.focusEffectDisabled(true)
				.help("Verlauf der letzten 10 Listeneinträge anzeigen")
				.onHover { hovering in
					isRecentHovered = hovering
				}

					// Assetklassen Zuklappen / Aufklappen
				Button {
					appState.collapse.setGlobalCollapsed(!appState.collapse.isGlobalCollapsed)
				} label: {
					toolbarIcon(
						systemName: appState.collapse.isGlobalCollapsed ? "book" : "book.closed",
						isHovered: isCollapseHovered
					)
				}
				.buttonStyle(ToolbarIconStyle())
				.focusable(false)
				.focusEffectDisabled(true)
				.help(appState.collapse.isGlobalCollapsed ? "Alle Assetklassen expandieren" : "Alle Assetklassen einklappen")
				.onHover { hovering in
					isCollapseHovered = hovering
				}

					// Neues Instrument
				Button {
					appState.enterCreateMode()
				} label: {
					toolbarIcon(systemName: "document.badge.plus", isHovered: isCreateHoveredLeft)
				}
				.buttonStyle(ToolbarIconStyle())
				.focusable(false)
				.focusEffectDisabled(true)
				.help("Neues Instrument anlegen")
				.onHover { hovering in
					isCreateHoveredLeft = hovering
				}

					// Instrument ändern
				Button {
					appState.enterEditModeForSelectedInstrument()
				} label: {
					toolbarIcon(
						systemName: "slider.horizontal.2.arrow.trianglehead.counterclockwise",
						isHovered: isEditHovered
					)
				}
				.buttonStyle(ToolbarIconStyle())
				.focusable(false)
				.focusEffectDisabled(true)
				.help("Instrument ändern")
				.onHover { hovering in
					isEditHovered = hovering
				}

					// Instrument löschen
				Button {

                    let inst: Instrument = appState.selectedInstrument!
                    instrumentToDelete = inst
                    showDeleteAlert = true
				} label: {
					toolbarIcon(systemName: "document.on.trash", isHovered: isDeleteHovered)
				}
				.buttonStyle(ToolbarIconStyle())
				.focusable(false)
				.focusEffectDisabled(true)
				.help("Instrument löschen")
				.onHover { hovering in
					isDeleteHovered = hovering
				}

			}
            .padding(16)
			.frame(width: sidebarWidth, alignment: .leading)

					// MITTLERER BEREICH – Tabs zentriert über dem Content
			ZStack {
				HStack(spacing: 18) {
					topTabButton(
						title: "Asset Ansicht",
						icon: "eye.fill",
						isActive: appState.navigation.workspaceMode == .instrumentsShowAndChange,
						isHovered: isShowHovered
					) {
						appState.switchToInstruments()
					}
					.onHover { hovering in
						isShowHovered = hovering
					}

					topTabButton(
						title: "Asset Anlage",
						icon: "doc.badge.plus",
						isActive: appState.navigation.workspaceMode == .instrumentsCreate,
						isHovered: isCreateHovered
					) {
						appState.enterCreateMode()
					}
					.onHover { hovering in
						isCreateHovered = hovering
					}

					topTabButton(
						title: "Asset Berechnen",
						icon: "function",
						isActive: appState.navigation.workspaceMode == .instrumentCalculation,
						isHovered: isCalcHovered
					) {
						appState.switchToCalculation()
					}
					.onHover { hovering in
						isCalcHovered = hovering
					}
				}
			}
			.frame(maxWidth: .infinity, alignment: .center)
			.alert("Achtung!", isPresented: $showDeleteAlert, presenting: instrumentToDelete) { inst in
				Button("Löschen", role: .destructive) {
					appState.deleteInstrument(inst)

				}
				Button("Abbrechen", role: .cancel) {}
			} message: { inst in
				Text("Soll das Instrument '\(inst.name)' wirklich gelöscht werden?")
			}
			.padding(.vertical, 8)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.workspaceGradientBackground()
	}

	private func topTabButton(
		title: String,
		icon: String,
		isActive: Bool,
		isHovered: Bool,
		action: @escaping () -> Void
	) -> some View {
		Button(action: action) {
			HStack(spacing: 8) {
				ZStack {
					Circle()
						.fill(
							LinearGradient(
								colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.55)],
								startPoint: .topLeading,
								endPoint: .bottomTrailing
							)
						)
						.shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
						.overlay(
							Circle()
								.stroke(Color.white.opacity(0.18), lineWidth: 1)
						)

	Circle()
		.stroke(Color(red: 1.0, green: 0.62, blue: 0.04).opacity(isHovered ? 0.75 : 0), lineWidth: 2)
		.blur(radius: isHovered ? 1 : 2)
		.animation(.easeInOut(duration: 0.14), value: isHovered)

					Circle()
						.fill(
							RadialGradient(
								colors: [Color.white.opacity(0.18), Color.clear],
								center: .topLeading,
								startRadius: 2,
								endRadius: 14
							)
						)
						.blendMode(.screen)

					Image(systemName: icon)
						.font(.system(size: 13, weight: .semibold))
						.foregroundColor(.white)
				}
				.frame(width: 26, height: 26)

				Text(title)
					.font(.subheadline)
					.fontWeight(.semibold)
					.foregroundColor(isActive ? .primary : .secondary)
			}
			.padding(.horizontal, 10)
			.padding(.vertical, 6)
			.background(
				RoundedRectangle(cornerRadius: 10)
					.fill(isActive ? Color.accentColor.opacity(0.12) : Color.clear)
			)
		}
		.buttonStyle(PressableToolbarStyle())
		.focusable(false)
		.focusEffectDisabled(true)
	}
}


private struct PressableToolbarStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.98 : 1)
			.animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
	}
}

private struct ToolbarIconStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.96 : 1)
			.animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
	}
}

private func toolbarIcon(systemName: String, isHovered: Bool) -> some View {
	ZStack {
		Circle()
			.fill(
				LinearGradient(
					colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.6)],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
			)
			.shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)

		Circle()
			.stroke(Color.white.opacity(0.18), lineWidth: 1)

	Circle()
		.stroke(Color(red: 1.0, green: 0.62, blue: 0.04).opacity(isHovered ? 0.75 : 0), lineWidth: 2)
		.blur(radius: isHovered ? 1 : 2)
		.animation(.easeInOut(duration: 0.14), value: isHovered)

		Circle()
			.fill(
				RadialGradient(
					colors: [Color.white.opacity(0.2), Color.clear],
					center: .topLeading,
					startRadius: 2,
					endRadius: 12
				)
			)
			.blendMode(.screen)

		Image(systemName: systemName)
			.font(.system(size: 12, weight: .semibold))
			.foregroundColor(.white)
	}
	.frame(width: 30, height: 30)
}
