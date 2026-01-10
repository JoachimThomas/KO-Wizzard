//
//  WorkspaceGradient.swift
//  KO-Wizzard
//

import SwiftUI

private struct WorkspaceSizeKey: EnvironmentKey {
	static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
	var workspaceSize: CGSize {
		get { self[WorkspaceSizeKey.self] }
		set { self[WorkspaceSizeKey.self] = newValue }
	}
}

struct WorkspaceSizePreferenceKey: PreferenceKey {
	static var defaultValue: CGSize = .zero

	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}

private enum WorkspaceGradient {
	static let colors = [
		Color.secondary.opacity(0.03),
		Color.secondary.opacity(0.05)
	]
}

private struct WorkspaceGradientBackground: ViewModifier {
	@Environment(\.workspaceSize) private var workspaceSize
	let cornerRadius: CGFloat?

	func body(content: Content) -> some View {
		content.background(
			GeometryReader { proxy in
				let frame = proxy.frame(in: .named("workspace"))
				let height = workspaceSize.height > 1 ? workspaceSize.height : proxy.size.height
				let startY = -frame.minY / max(height, 1)
				let endY = (height - frame.minY) / max(height, 1)

				let gradient = LinearGradient(
					colors: WorkspaceGradient.colors,
					startPoint: UnitPoint(x: 0.5, y: startY),
					endPoint: UnitPoint(x: 0.5, y: endY)
				)

				Group {
					if let cornerRadius {
						gradient.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
					} else {
						gradient
					}
				}
			}
		)
	}
}

extension View {
	func workspaceGradientBackground(cornerRadius: CGFloat? = nil) -> some View {
		modifier(WorkspaceGradientBackground(cornerRadius: cornerRadius))
	}
}
