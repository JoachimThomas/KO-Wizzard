//
//  Font+Menlo.swift
//  KO-Wizzard
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension Font {
	static func menlo(textStyle: Font.TextStyle) -> Font {
		#if os(iOS)
		let uiStyle: UIFont.TextStyle
		switch textStyle {
			case .largeTitle: uiStyle = .largeTitle
			case .title: uiStyle = .title1
			case .title2: uiStyle = .title2
			case .title3: uiStyle = .title3
			case .headline: uiStyle = .headline
			case .subheadline: uiStyle = .subheadline
			case .callout: uiStyle = .callout
			case .caption: uiStyle = .caption1
			case .caption2: uiStyle = .caption2
			case .footnote: uiStyle = .footnote
			default: uiStyle = .body
		}
		let size = UIFont.preferredFont(forTextStyle: uiStyle).pointSize
		return .custom("Menlo", size: size)
		#elseif os(macOS)
		let nsStyle: NSFont.TextStyle
		switch textStyle {
			case .largeTitle: nsStyle = .largeTitle
			case .title: nsStyle = .title1
			case .title2: nsStyle = .title2
			case .title3: nsStyle = .title3
			case .headline: nsStyle = .headline
			case .subheadline: nsStyle = .subheadline
			case .callout: nsStyle = .callout
			case .caption: nsStyle = .caption1
			case .caption2: nsStyle = .caption2
			case .footnote: nsStyle = .footnote
			default: nsStyle = .body
		}
		let size = NSFont.preferredFont(forTextStyle: nsStyle).pointSize
		return .custom("Menlo", size: size)
		#else
		return .custom("Menlo", size: 13)
		#endif
	}
}
