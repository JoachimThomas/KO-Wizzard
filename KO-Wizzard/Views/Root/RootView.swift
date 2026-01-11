import SwiftUI
import Foundation
import UserNotifications

struct RootView: View {

    @EnvironmentObject var appState: AppStateEngine

        // Definiere deinen spezifischen Blauton, falls er von Apples Standard abweicht
        // Color(red: 0/255, green: 122/255, blue: 255/255) ist Apples Systemblau
    private let appBlue = Color(red: 0.0, green: 0.48, blue: 1.0) // Beispiel für einen etwas tieferen, gesättigten Blauton

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
                    LinearGradient(
                        colors: [
                            appBlue.opacity(0.8), // Oberer Rand (dunkler und blickdichter)
                            appBlue.opacity(0.5)  // Unterer Rand (etwas heller)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.multiply) // Natürliche Verschmelzung mit dem Material
                )
                .frame(height: 28) // Feste Höhe der macOS Titlebar
                .ignoresSafeArea(.container, edges: .top) // Füllt denBereich hinter den Buttons
                .allowsHitTesting(false)
                // Optional: Eine feine Trennlinie zum Content
            VStack {
                Spacer().frame(height: 28)
                Divider().opacity(0.3)
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
