import SwiftUI

struct SubgroupPickerSheet: View {

	let subgroups: [Subgroup]
	let current: Subgroup?              // aktueller Wert im Draft
	let onSelect: (Subgroup) -> Void

	@Environment(\.dismiss) private var dismiss

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Subgroup wählen")
				.font(.menlo(textStyle: .headline))
				.padding(.top, 12)

			ScrollView {
				VStack(alignment: .leading, spacing: 8) {
					ForEach(subgroups) { item in
						let isSelected = (item == current)

						Button {
							onSelect(item)
							dismiss()
						} label: {
							HStack {
								Text(item.displayName)
								Spacer()
								if isSelected {
									Image(systemName: "checkmark")
								}
							}
							.padding(.vertical, 4)
						}
						.buttonStyle(.plain)
					}
				}
				.padding(.vertical, 8)
			}

			Divider()

			HStack {
				Spacer()
				Button("Abbrechen") {
					dismiss()
				}
			}
			.padding(.bottom, 10)
		}
		.padding(.horizontal, 16)
		.frame(minWidth: 320, minHeight: 380)
		.font(.menlo(textStyle: .body))
	}
}
