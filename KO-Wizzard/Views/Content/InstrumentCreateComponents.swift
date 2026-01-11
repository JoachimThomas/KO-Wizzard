//
//  InstrumentCreateComponents.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 26.11.25.


import SwiftUI

	/// Generischer Picker-Step mit Dummy-Zeile "–"
struct PickerStepView<T: Hashable>: View {

	@Environment(\.appTheme) private var theme
	let title: String
	let values: [(T, String)]
	let current: T?
	let onSelect: (T) -> Void

	@State private var selection: T?

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(title)
				.font(theme.fonts.subheadline)
				.foregroundColor(theme.colors.textSecondary)

			Picker("", selection: Binding(
				get: { selection },
				set: { selection = $0 }
			)) {
				Text("–")
					.tag(nil as T?)

				ForEach(values, id: \.0) { pair in
					Text(pair.1).tag(Optional(pair.0))
				}
			}
			.pickerStyle(.menu)
		}
		.onAppear {
			if selection == nil {
				selection = current
			}
		}
		.onChange(of: selection) { _, newValue in
			if let value = newValue {
				onSelect(value)
			}
		}
	}
}

	/// Convenience-Funktion für einen Picker-Step
func pickerStep<T: Hashable>(
	title: String,
	values: [(T, String)],
	selected: T?,
	onSelect: @escaping (T) -> Void
) -> some View {
	PickerStepView(
		title: title,
		values: values,
		current: selected,
		onSelect: onSelect
	)
}

	/// Standardisierter Button für Sheet-basierte Eingaben
func sheetInputButton(
	title: String,
	value: String,
	theme: AppTheme,
	action: @escaping () -> Void
) -> some View {
	Button(action: action) {
		HStack {
			Text(title)
			Spacer()
			Text(value.isEmpty ? "–" : value)
				.foregroundColor(theme.colors.textSecondary)
		}
		.padding(theme.metrics.paddingSmall)
		.background(theme.colors.inputBackground)
		.cornerRadius(theme.metrics.sheetCornerRadius)
	}
}
