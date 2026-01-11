import SwiftUI
import Foundation
import UserNotifications

struct RootView: View {

    @EnvironmentObject var appState: AppStateEngine
	@Environment(\.appTheme) private var baseTheme
	@Environment(\.colorScheme) private var colorScheme
#if DEBUG
	@AppStorage("debugThemeMode") private var debugThemeModeRaw: String = ThemeMode.system.rawValue
#endif

	private var resolvedTheme: AppTheme {
		AppTheme(mode: baseTheme.mode, systemColorScheme: colorScheme)
	}

    var body: some View {
		let theme = resolvedTheme
		GeometryReader { proxy in
			let topInset = max(0, theme.metrics.titlebarHeight - proxy.safeAreaInsets.top)
			ZStack(alignment: .top) {
					// 1. Der eigentliche Content der App
				Group {
					if appState.navigation.isLandingVisible {
						LandingView()
					} else {
						WorkspaceView()
					}
				}
				.padding(.top, topInset)
				.frame(maxWidth: .infinity, maxHeight: .infinity)

					// 2. Die eingefärbte Titlebar mit Material und dunklerem Verlauf
				Rectangle()
					.fill(.ultraThinMaterial) // Basis-Material für den Glas-Effekt
					.overlay(
						theme.gradients.titlebar(theme.colors)
						.blendMode(theme.chromeBlendMode) // Natürliche Verschmelzung je Modus
					)
					.frame(height: theme.metrics.titlebarHeight) // Feste Höhe der macOS Titlebar
					.ignoresSafeArea(.container, edges: .top) // Füllt denBereich hinter den Buttons
					.allowsHitTesting(false)
					// Optional: Eine feine Trennlinie zum Content
				VStack {
					Spacer().frame(height: theme.metrics.titlebarHeight)
					Divider().opacity(theme.effects.titlebarDividerOpacity)
					Spacer()
				}
				.ignoresSafeArea(.container, edges: .top)
				.allowsHitTesting(false)
			}
		}
		.appTheme(theme)
		.tint(theme.colors.chromeAccent)
#if DEBUG
		.overlay(alignment: .bottomTrailing) {
			debugThemeControl
		}
#endif
            // System-Hintergrund der Toolbar ausblenden
        .toolbarBackground(.hidden, for: .windowToolbar)
        .toolbarBackground(.hidden, for: .automatic)
	}

#if DEBUG
	private var debugThemeControl: some View {
		HStack(spacing: 8) {
			Text("Theme")
				.font(.caption2)
			Picker("", selection: $debugThemeModeRaw) {
				Text("System").tag(ThemeMode.system.rawValue)
				Text("Hell").tag(ThemeMode.light.rawValue)
				Text("Dunkel").tag(ThemeMode.dark.rawValue)
			}
			.pickerStyle(.segmented)
			.frame(width: 180)
		}
		.padding(8)
		.background(.ultraThinMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 8))
		.padding(12)
	}
#endif
}

#Preview {
    RootView()
        .environmentObject(AppStateEngine())
}
