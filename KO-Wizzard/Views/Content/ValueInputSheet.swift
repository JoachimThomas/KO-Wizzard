	//
	//  ValueInputSheet.swift
	//  KO-Wizzard
	//

import SwiftUI
#if os(iOS)
import UIKit
#endif

	/// Allgemeines Eingabe-Sheet für Text / isin / numerische Werte
struct ValueInputSheet: View {

	enum InputKind {
		case stockName     // freier Text
		case isin           // freier Text, wird uppercased
		case numeric       // 0–9, Komma, Punkt→Komma
	}

	let title: String
	let message: String
	let kind: InputKind
	let initialValue: String
	let onCommit: (String) -> Void
	let onCancel: () -> Void

	@State private var text: String = ""

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {

			Text(title)
				.font(.headline)

			if !message.isEmpty {
				Text(message)
					.font(.subheadline)
					.foregroundColor(.secondary)
			}

				// MARK: - Eingabefeld (iOS mit Auto-Fokus, macOS normal)

			inputField
				.onChange(of: text) { _, newValue in
					switch kind {
						case .stockName:
							break

						case .isin:
							let upper = newValue.uppercased()
							if upper != newValue {
								text = upper
							}

						case .numeric:
							let cleaned = InputSanitizer.numeric(newValue)
							if cleaned != newValue {
								text = cleaned
							}
					}
				}

			HStack {
				Spacer()
				Button("Abbrechen") {
					onCancel()
				}
				Button("Übernehmen") {
					let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
					onCommit(trimmed)
				}
				.buttonStyle(.borderedProminent)
				.disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
			}
		}
		.padding()
		.presentationDetents([.medium])
		.onAppear {
			text = initialValue
		}
	}

		// MARK: - InputField je Plattform

	@ViewBuilder
	private var inputField: some View {
#if os(iOS)
		FirstResponderTextField(
			text: $text,
			keyboardType: kind == .numeric ? .decimalPad : .default,
			onReturn: {
				let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
				if !trimmed.isEmpty {
					onCommit(trimmed)
				}
			}
		)
		.frame(maxWidth: .infinity)
#else
		TextField("", text: $text)
			.textFieldStyle(.roundedBorder)
			.onSubmit {
				let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
				if !trimmed.isEmpty {
					onCommit(trimmed)
				}
			}
#endif
	}

#if os(iOS)
		/// UIKit-TextField, das beim Erscheinen automatisch First Responder wird.
	private struct FirstResponderTextField: UIViewRepresentable {

		@Binding var text: String
		let keyboardType: UIKeyboardType
		let onReturn: () -> Void

		class Coordinator: NSObject, UITextFieldDelegate {
			@Binding var text: String
			let onReturn: () -> Void

			init(text: Binding<String>, onReturn: @escaping () -> Void) {
				_text = text
				self.onReturn = onReturn
			}

			func textFieldDidChangeSelection(_ textField: UITextField) {
				text = textField.text ?? ""
			}

			func textFieldShouldReturn(_ textField: UITextField) -> Bool {
				onReturn()
				return true
			}
		}

		func makeCoordinator() -> Coordinator {
			Coordinator(text: $text, onReturn: onReturn)
		}

		func makeUIView(context: Context) -> UITextField {
			let tf = UITextField(frame: .zero)
			tf.delegate = context.coordinator
			tf.borderStyle = .roundedRect
			tf.keyboardType = keyboardType
			tf.returnKeyType = .done

				// Initialwert
			tf.text = text

				// Auto-Fokus, sobald das Feld in der Hierarchie hängt
			DispatchQueue.main.async {
				tf.becomeFirstResponder()
			}

			return tf
		}

		func updateUIView(_ uiView: UITextField, context: Context) {
			if uiView.text != text {
				uiView.text = text
			}
			uiView.keyboardType = keyboardType
		}
	}
#endif
}
