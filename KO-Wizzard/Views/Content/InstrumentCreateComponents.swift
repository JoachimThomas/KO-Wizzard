//
//  InstrumentCreateComponents.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 26.11.25.


import SwiftUI

	/// Generischer Picker-Step mit Dummy-Zeile "–"
struct PickerStepView<T: Hashable>: View {

	let title: String
	let values: [(T, String)]
	let current: T?
	let onSelect: (T) -> Void

	@State private var selection: T?

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(title)
				.font(.menlo(textStyle: .subheadline))
				.foregroundColor(.secondary)

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
func sheetInputButton(title: String, value: String, action: @escaping () -> Void) -> some View {
	Button(action: action) {
		HStack {
			Text(title)
			Spacer()
			Text(value.isEmpty ? "–" : value)
				.foregroundColor(.secondary)
		}
		.padding(8)
		.background(Color.secondary.opacity(0.08))
		.cornerRadius(8)
	}
}
