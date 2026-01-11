//
//  AppTheme.swift
//  KO-Wizzard
//

import SwiftUI

enum ThemeMode: String {
	case system
	case light
	case dark
}

struct AppColors {
	let mode: ThemeMode

	private func resolve(light: Color, dark: Color) -> Color {
		switch mode {
		case .dark:
			return dark
		case .light, .system:
			return light
		}
	}

	var primaryBlue: Color { Color(red: 0.0, green: 0.48, blue: 1.0) }
	var accentOrange: Color { Color(red: 1.0, green: 0.62, blue: 0.04) }
	var actionBlue: Color { resolve(light: .blue, dark: .blue) }
	var alertRed: Color { .red }
	var alertRedMuted: Color { resolve(light: Color.red.opacity(0.8), dark: Color.red.opacity(0.8)) }
	var successGreen: Color { resolve(light: .green, dark: .green) }
	var textPrimary: Color { resolve(light: .primary, dark: .primary) }
	var textSecondary: Color { resolve(light: .secondary, dark: .secondary) }
	var cardBackground: Color {
		resolve(light: Color.secondary.opacity(0.05), dark: Color.white.opacity(0.06))
	}
	var workspaceGradientTop: Color {
		resolve(light: Color.secondary.opacity(0.03), dark: Color.white.opacity(0.03))
	}
	var workspaceGradientBottom: Color {
		resolve(light: Color.secondary.opacity(0.05), dark: Color.white.opacity(0.05))
	}
	var sidebarSelection: Color {
		resolve(light: Color.black.opacity(0.08), dark: Color.white.opacity(0.08))
	}
	var sidebarSearchBackground: Color {
		resolve(light: Color.white.opacity(0.08), dark: Color.white.opacity(0.06))
	}
	var sidebarText: Color { resolve(light: Color.black.opacity(0.88), dark: Color.white.opacity(0.9)) }
	var sidebarHeaderText: Color { resolve(light: Color.black.opacity(0.88), dark: Color.white.opacity(0.9)) }
	var sidebarSubgroupText: Color { resolve(light: Color.black.opacity(0.75), dark: Color.white.opacity(0.8)) }
	var sidebarDirectionText: Color { resolve(light: Color.black.opacity(0.65), dark: Color.white.opacity(0.7)) }
	var sidebarChevron: Color { resolve(light: Color.black.opacity(0.65), dark: Color.white.opacity(0.7)) }
	var sidebarChevronMuted: Color { resolve(light: Color.black.opacity(0.55), dark: Color.white.opacity(0.6)) }
	var sidebarIndicatorEmpty: Color { resolve(light: Color.gray.opacity(0.3), dark: Color.white.opacity(0.3)) }
	var sidebarIndicatorActive: Color { resolve(light: Color.green.opacity(0.9), dark: Color.green.opacity(0.8)) }
	var sidebarIndicatorFavorite: Color { resolve(light: .yellow, dark: .yellow) }
	var sidebarIndicatorRecent: Color { resolve(light: .red, dark: .red) }
	var divider: Color { resolve(light: Color.primary.opacity(0.2), dark: Color.white.opacity(0.2)) }
	var strokeLight: Color { resolve(light: Color.white.opacity(0.18), dark: Color.white.opacity(0.2)) }
	var highlightLight: Color { resolve(light: Color.white.opacity(0.2), dark: Color.white.opacity(0.25)) }
	var footerText: Color { resolve(light: .white, dark: .white) }
	var inputBackground: Color {
		resolve(light: Color.secondary.opacity(0.08), dark: Color.white.opacity(0.08))
	}
	var toolbarTabActiveBackground: Color {
		resolve(light: Color.accentColor.opacity(0.12), dark: Color.accentColor.opacity(0.2))
	}
	var toolbarIconForeground: Color { resolve(light: .white, dark: .white) }
}

struct AppFonts {
	let mode: ThemeMode

	var body: Font { .menlo(textStyle: .body) }
	var headline: Font { .menlo(textStyle: .headline) }
	var subheadline: Font { .menlo(textStyle: .subheadline) }
	var footnote: Font { .menlo(textStyle: .footnote) }
	var footerSmall: Font { .custom("Menlo", size: 11) }
	var toolbarIcon: Font { .system(size: 12, weight: .semibold) }
	var toolbarTab: Font { .subheadline.weight(.semibold) }
	var importButton: Font { .custom("Menlo", size: 12).weight(.medium) }
	var sidebarRow: Font { .custom("Menlo", size: 14) }
	var sidebarHeader: Font { .custom("Menlo", size: 13).weight(.semibold) }
	var sidebarSubgroup: Font { .custom("Menlo", size: 12) }
	var sidebarDirection: Font { .custom("Menlo", size: 11).weight(.medium) }
	var sidebarChevron: Font { .system(size: 12, weight: .bold) }
	var sidebarChevronSmall: Font { .system(size: 10, weight: .bold) }
	var sidebarSearch: Font { .custom("Menlo", size: 12) }
}

struct Metrics {
	var cardCornerRadius: CGFloat { 14 }
	var panelCornerRadius: CGFloat { 16 }
	var sheetCornerRadius: CGFloat { 8 }
	var toolbarHeight: CGFloat { 48 }
	var sidebarWidth: CGFloat { 300 }
	var titlebarHeight: CGFloat { 28 }
	var sidebarRowCornerRadius: CGFloat { 6 }
	var sidebarRowPaddingH: CGFloat { 18 }
	var sidebarRowPaddingV: CGFloat { 6 }
	var sidebarSearchCornerRadius: CGFloat { 6 }
	var sidebarSearchHeight: CGFloat { 30 }
	var sidebarSearchIconSize: CGFloat { 11 }
	var sidebarSearchPaddingH: CGFloat { 8 }
	var sidebarSearchPaddingTop: CGFloat { 8 }
	var sidebarSearchPaddingBottom: CGFloat { 6 }
	var sidebarListSpacing: CGFloat { 10 }
	var sidebarGroupSpacing: CGFloat { 4 }
	var sidebarGroupPaddingH: CGFloat { 10 }
	var sidebarGroupPaddingV: CGFloat { 6 }
	var sidebarSubgroupPaddingH: CGFloat { 16 }
	var sidebarSubgroupPaddingTop: CGFloat { 4 }
	var sidebarDirectionPaddingH: CGFloat { 18 }
	var sidebarDirectionPaddingTop: CGFloat { 4 }
	var sidebarDirectionPaddingTopAlt: CGFloat { 6 }
	var sidebarFooterPaddingV: CGFloat { 8 }
	var toolbarTabCornerRadius: CGFloat { 10 }
	var toolbarTabPaddingH: CGFloat { 10 }
	var toolbarTabPaddingV: CGFloat { 6 }
	var toolbarTabIconSize: CGFloat { 13 }
	var toolbarTabIconCircle: CGFloat { 26 }
	var paddingSmall: CGFloat { 8 }
	var paddingMedium: CGFloat { 12 }
	var paddingLarge: CGFloat { 16 }
	var paddingXSmall: CGFloat { 4 }
	var paddingTight: CGFloat { 10 }
	var contentPaddingH: CGFloat { 18 }
	var sheetMinWidth: CGFloat { 320 }
	var sheetMinHeight: CGFloat { 380 }
	var spacingSmall: CGFloat { 8 }
	var spacingMedium: CGFloat { 12 }
	var spacingLarge: CGFloat { 20 }
}

struct Gradients {
	func titlebar(_ colors: AppColors) -> LinearGradient {
		LinearGradient(
			colors: [
				colors.primaryBlue.opacity(0.8),
				colors.primaryBlue.opacity(0.5)
			],
			startPoint: .top,
			endPoint: .bottom
		)
	}

	func footer(_ colors: AppColors) -> LinearGradient {
		LinearGradient(
			colors: [
				colors.primaryBlue.opacity(0.5),
				colors.primaryBlue.opacity(0.8)
			],
			startPoint: .top,
			endPoint: .bottom
		)
	}

	func toolbarIcon(_ colors: AppColors) -> LinearGradient {
		LinearGradient(
			colors: [colors.primaryBlue.opacity(0.9), colors.primaryBlue.opacity(0.6)],
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		)
	}

	func toolbarIconHighlight(_ colors: AppColors) -> RadialGradient {
		RadialGradient(
			colors: [colors.highlightLight, Color.clear],
			center: .topLeading,
			startRadius: 2,
			endRadius: 12
		)
	}

	func landingButton(_ colors: AppColors) -> LinearGradient {
		LinearGradient(
			colors: [colors.primaryBlue.opacity(0.95), colors.primaryBlue.opacity(0.65)],
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		)
	}
}

struct Effects {
	var shadowSoft: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
		(Color.black.opacity(0.2), 3, 0, 2)
	}

	var shadowElevated: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
		(Color.black.opacity(0.25), 6, 0, 4)
	}

	var hoverGlowOpacity: Double { 0.75 }
	var titlebarDividerOpacity: Double { 0.3 }
	var pressScaleSmall: CGFloat { 0.98 }
	var pressScaleMedium: CGFloat { 0.96 }
	var pressAnimation: Animation { .easeInOut(duration: 0.12) }
	var hoverAnimation: Animation { .easeInOut(duration: 0.14) }
}

struct AppTheme {
	var mode: ThemeMode = .system
	var colors: AppColors { AppColors(mode: mode) }
	var fonts: AppFonts { AppFonts(mode: mode) }
	var metrics: Metrics { Metrics() }
	var gradients: Gradients { Gradients() }
	var effects: Effects { Effects() }

	init(mode: ThemeMode = .system) {
		self.mode = mode
	}
}

extension EnvironmentValues {
	var appTheme: AppTheme {
		get { self[AppThemeKey.self] }
		set { self[AppThemeKey.self] = newValue }
	}
}

private struct AppThemeKey: EnvironmentKey {
	static let defaultValue = AppTheme()
}

extension View {
	func appTheme(_ theme: AppTheme) -> some View {
		environment(\.appTheme, theme)
	}
}
