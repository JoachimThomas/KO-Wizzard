//
//  AppStyleModifiers.swift
//  KO-Wizzard
//

import SwiftUI

struct AppCardStyle: ViewModifier {
	@Environment(\.appTheme) private var theme

	func body(content: Content) -> some View {
		content
			.padding()
			.background(theme.colors.cardBackground)
			.cornerRadius(theme.metrics.cardCornerRadius)
	}
}

struct AppFooterStyle: ViewModifier {
	@Environment(\.appTheme) private var theme

	func body(content: Content) -> some View {
		content
			.background(
				ZStack {
					Rectangle().fill(.ultraThinMaterial)
					theme.gradients.footer(theme.colors).blendMode(.multiply)
				}
			)
	}
}

struct AppTitlebarOverlayStyle: ViewModifier {
	@Environment(\.appTheme) private var theme

	func body(content: Content) -> some View {
		content
			.background(.ultraThinMaterial)
			.overlay(
				theme.gradients.titlebar(theme.colors)
					.blendMode(.multiply)
			)
	}
}

struct AppToolbarTabStyle: ButtonStyle {
	@Environment(\.appTheme) private var theme
	let isActive: Bool

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding(.horizontal, 10)
			.padding(.vertical, 6)
			.background(
				RoundedRectangle(cornerRadius: 10)
					.fill(isActive ? Color.accentColor.opacity(0.12) : Color.clear)
			)
			.scaleEffect(configuration.isPressed ? theme.effects.pressScaleSmall : 1)
			.animation(theme.effects.pressAnimation, value: configuration.isPressed)
	}
}

struct AppIconButtonStyle: ButtonStyle {
	@Environment(\.appTheme) private var theme

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? theme.effects.pressScaleMedium : 1)
			.animation(theme.effects.pressAnimation, value: configuration.isPressed)
	}
}

struct AppFocusRingDisabled: ViewModifier {
	func body(content: Content) -> some View {
		content
			.focusable(false)
			.focusEffectDisabled(true)
	}
}

extension View {
	func appCardStyle() -> some View { modifier(AppCardStyle()) }
	func appFooterStyle() -> some View { modifier(AppFooterStyle()) }
	func appTitlebarOverlayStyle() -> some View { modifier(AppTitlebarOverlayStyle()) }
	func appFocusRingDisabled() -> some View { modifier(AppFocusRingDisabled()) }
}
