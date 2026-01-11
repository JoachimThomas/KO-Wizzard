//
//  AppTheme.swift
//  KO-Wizzard
//

import SwiftUI

enum ThemeMode {
	case system
	case light
	case dark
}

struct AppColors {
	let mode: ThemeMode

	var primaryBlue: Color { Color(red: 0.0, green: 0.48, blue: 1.0) }
	var accentOrange: Color { Color(red: 1.0, green: 0.62, blue: 0.04) }
	var alertRed: Color { .red }
	var textPrimary: Color { .primary }
	var textSecondary: Color { .secondary }
	var cardBackground: Color { Color.secondary.opacity(0.05) }
	var sidebarSelection: Color { Color.black.opacity(0.08) }
	var sidebarSearchBackground: Color { Color.white.opacity(0.08) }
	var sidebarText: Color { Color.black.opacity(0.88) }
	var divider: Color { Color.primary.opacity(0.2) }
	var strokeLight: Color { Color.white.opacity(0.18) }
	var highlightLight: Color { Color.white.opacity(0.2) }
	var footerText: Color { .white }
	var inputBackground: Color { Color.secondary.opacity(0.08) }
	var toolbarTabActiveBackground: Color { Color.accentColor.opacity(0.12) }
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
	var toolbarTabCornerRadius: CGFloat { 10 }
	var toolbarTabPaddingH: CGFloat { 10 }
	var toolbarTabPaddingV: CGFloat { 6 }
	var toolbarTabIconSize: CGFloat { 13 }
	var toolbarTabIconCircle: CGFloat { 26 }
	var paddingSmall: CGFloat { 8 }
	var paddingMedium: CGFloat { 12 }
	var paddingLarge: CGFloat { 16 }
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
