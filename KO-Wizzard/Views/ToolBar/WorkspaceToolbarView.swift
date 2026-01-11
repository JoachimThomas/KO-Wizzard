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
	@Environment(\.appTheme) private var theme
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
					appState.collapse.setGlobalCollapsed(false)
				} label: {
					toolbarIcon(
						systemName: "chart.line.uptrend.xyaxis",
						isHovered: isAllHovered,
						theme: theme
					)
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
						isHovered: isFavoritesHovered,
						theme: theme
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
					toolbarIcon(
						systemName: "clock",
						isHovered: isRecentHovered,
						theme: theme
					)
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
						isHovered: isCollapseHovered,
						theme: theme
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
					toolbarIcon(
						systemName: "document.badge.plus",
						isHovered: isCreateHoveredLeft,
						theme: theme
					)
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
						isHovered: isEditHovered,
						theme: theme
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
					toolbarIcon(
						systemName: "document.on.trash",
						isHovered: isDeleteHovered,
						theme: theme
					)
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
								colors: [
									theme.colors.primaryBlue.opacity(0.9),
									theme.colors.primaryBlue.opacity(0.55)
								],
								startPoint: .topLeading,
								endPoint: .bottomTrailing
							)
						)
						.shadow(
							color: theme.effects.shadowSoft.color,
							radius: theme.effects.shadowSoft.radius,
							x: theme.effects.shadowSoft.x,
							y: theme.effects.shadowSoft.y
						)
						.overlay(
							Circle()
								.stroke(theme.colors.strokeLight, lineWidth: 1)
						)

	Circle()
		.stroke(
			theme.colors.accentOrange.opacity(isHovered ? theme.effects.hoverGlowOpacity : 0),
			lineWidth: 2
		)
		.blur(radius: isHovered ? 1 : 2)
		.animation(theme.effects.hoverAnimation, value: isHovered)

					Circle()
						.fill(
							RadialGradient(
								colors: [theme.colors.highlightLight, Color.clear],
								center: .topLeading,
								startRadius: 2,
								endRadius: 14
							)
						)
						.blendMode(.screen)

					Image(systemName: icon)
						.font(.system(size: theme.metrics.toolbarTabIconSize, weight: .semibold))
						.foregroundColor(theme.colors.toolbarIconForeground)
				}
				.frame(width: theme.metrics.toolbarTabIconCircle, height: theme.metrics.toolbarTabIconCircle)

				Text(title)
					.font(theme.fonts.toolbarTab)
					.foregroundColor(isActive ? theme.colors.textPrimary : theme.colors.textSecondary)
			}
			.padding(.horizontal, theme.metrics.toolbarTabPaddingH)
			.padding(.vertical, theme.metrics.toolbarTabPaddingV)
			.background(
				RoundedRectangle(cornerRadius: theme.metrics.toolbarTabCornerRadius)
					.fill(isActive ? theme.colors.toolbarTabActiveBackground : Color.clear)
			)
		}
		.buttonStyle(PressableToolbarStyle())
		.focusable(false)
		.focusEffectDisabled(true)
	}
}


private struct PressableToolbarStyle: ButtonStyle {
	@Environment(\.appTheme) private var theme

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? theme.effects.pressScaleSmall : 1)
			.animation(theme.effects.pressAnimation, value: configuration.isPressed)
	}
}

private struct ToolbarIconStyle: ButtonStyle {
	@Environment(\.appTheme) private var theme

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? theme.effects.pressScaleMedium : 1)
			.animation(theme.effects.pressAnimation, value: configuration.isPressed)
	}
}

private func toolbarIcon(systemName: String, isHovered: Bool, theme: AppTheme) -> some View {
	ZStack {
		Circle()
			.fill(theme.gradients.toolbarIcon(theme.colors))
			.shadow(
				color: theme.effects.shadowSoft.color,
				radius: theme.effects.shadowSoft.radius,
				x: theme.effects.shadowSoft.x,
				y: theme.effects.shadowSoft.y
			)

		Circle()
			.stroke(theme.colors.strokeLight, lineWidth: 1)

	Circle()
		.stroke(
			theme.colors.accentOrange.opacity(isHovered ? theme.effects.hoverGlowOpacity : 0),
			lineWidth: 2
		)
		.blur(radius: isHovered ? 1 : 2)
		.animation(theme.effects.hoverAnimation, value: isHovered)

	Circle()
		.fill(theme.gradients.toolbarIconHighlight(theme.colors))
		.blendMode(.screen)

	Image(systemName: systemName)
		.font(theme.fonts.toolbarIcon)
		.foregroundColor(theme.colors.toolbarIconForeground)
	}
	.frame(width: 30, height: 30)
}
