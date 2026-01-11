import SwiftUI
import Foundation
import UserNotifications

struct RootView: View {

    @EnvironmentObject var appState: AppStateEngine
	@Environment(\.appTheme) private var theme

    var body: some View {
        ZStack(alignment: .top) {
                // 1. Der eigentliche Content der App
            Group {
                if appState.navigation.isLandingVisible {
                    LandingView()
                } else {
                    WorkspaceView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 2. Die eingefärbte Titlebar mit Material und dunklerem Verlauf
            Rectangle()
                .fill(.ultraThinMaterial) // Basis-Material für den Glas-Effekt
                .overlay(
					theme.gradients.titlebar(theme.colors)
                    .blendMode(.multiply) // Natürliche Verschmelzung mit dem Material
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
            // System-Hintergrund der Toolbar ausblenden
        .toolbarBackground(.hidden, for: .windowToolbar)
        .toolbarBackground(.hidden, for: .automatic)
	}
}

#Preview {
    RootView()
        .environmentObject(AppStateEngine())
}
