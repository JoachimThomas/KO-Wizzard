import SwiftUI

struct SubgroupPickerSheet: View {

	let subgroups: [Subgroup]
	let current: Subgroup?              // aktueller Wert im Draft
	let onSelect: (Subgroup) -> Void

	@Environment(\.dismiss) private var dismiss
	@Environment(\.appTheme) private var theme

	var body: some View {
		VStack(alignment: .leading, spacing: theme.metrics.paddingMedium) {
			Text("Subgroup wählen")
				.font(theme.fonts.headline)
				.padding(.top, theme.metrics.paddingMedium)

			ScrollView {
				VStack(alignment: .leading, spacing: theme.metrics.paddingSmall) {
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
							.padding(.vertical, theme.metrics.paddingXSmall)
						}
						.buttonStyle(.plain)
					}
				}
				.padding(.vertical, theme.metrics.paddingSmall)
			}

			Divider()

			HStack {
				Spacer()
				Button("Abbrechen") {
					dismiss()
				}
			}
			.padding(.bottom, theme.metrics.paddingTight)
		}
		.padding(.horizontal, theme.metrics.paddingLarge)
		.frame(minWidth: theme.metrics.sheetMinWidth, minHeight: theme.metrics.sheetMinHeight)
		.font(theme.fonts.body)
	}
}
