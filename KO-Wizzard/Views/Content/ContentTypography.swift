//
//  ContentTypography.swift
//  KO-Wizzard
//

import SwiftUI

enum ContentEmphasisKind {
	case standard
	case identifier
}

private struct ContentEmphasisModifier: ViewModifier {
	let kind: ContentEmphasisKind

	func body(content: Content) -> some View {
		content.tracking(kind == .identifier ? 0.48 : 0.4)
	}
}

extension View {
	func contentEmphasis(_ kind: ContentEmphasisKind = .standard) -> some View {
		modifier(ContentEmphasisModifier(kind: kind))
	}
}
