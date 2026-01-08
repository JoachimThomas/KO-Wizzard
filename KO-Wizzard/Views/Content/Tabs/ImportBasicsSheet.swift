//
//  ImportBasicsSheet.swift
//  KO-Wizzard
//
//  Created by Joachim Thomas on 25.11.25.
//
// MARK: - ImportBasicsSheet
import SwiftUI

struct ImportBasicsSheet: View {
	@Binding var text: String
	@Binding var errorMessage: String?

	let onImport: () -> Void
	let onCancel: () -> Void

	var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 12) {
				Text("Webseitentext einfügen")
					.font(.headline)

				Text("Kopieren Sie den Produkttext (z. B. von HSBC, onvista, finanzen.net) und fügen Sie ihn hier ein. Die App versucht dann, die Basisdaten automatisch zu erkennen.")
					.font(.footnote)
					.foregroundColor(.secondary)

				TextEditor(text: $text)
					.font(.system(size: 13, weight: .regular, design: .monospaced))
					.frame(minHeight: 220)
					.overlay(
						RoundedRectangle(cornerRadius: 8)
							.stroke(Color.secondary.opacity(0.3))
					)

				if let error = errorMessage {
					Text(error)
						.font(.footnote)
						.foregroundColor(.red)
				}

				Spacer()

				HStack {
					Button("Abbrechen") {
						onCancel()
					}

					Spacer()

					Button("Importieren") {
						onImport()
					}
					.buttonStyle(.borderedProminent)
					.disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				}
			}
			.padding()
			
		}
	}
}
