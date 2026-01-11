import SwiftUI
import Foundation
import UserNotifications

struct RootView: View {

    @EnvironmentObject var appState: AppStateEngine
	@Environment(\.appTheme) private var baseTheme
	@Environment(\.colorScheme) private var colorScheme
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
			.overlay(
				Rectangle()
					.stroke(theme.colors.windowBorder, lineWidth: theme.metrics.windowBorderWidth)
					.ignoresSafeArea()
					.allowsHitTesting(false)
			)
		}
		.appTheme(theme)
		.tint(theme.colors.chromeAccent)
            // System-Hintergrund der Toolbar ausblenden
        .toolbarBackground(.hidden, for: .windowToolbar)
        .toolbarBackground(.hidden, for: .automatic)
	}
}

#Preview {
    RootView()
        .environmentObject(AppStateEngine())
}
