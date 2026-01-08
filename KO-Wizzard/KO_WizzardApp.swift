import SwiftUI
import Foundation
import UserNotifications
import Combine

@main
struct KO_WizardApp: App {

	@StateObject private var appState = AppStateEngine()

	init() {
			// Optional: Notifications erlauben
		UNUserNotificationCenter.current()
			.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
	}

	var body: some Scene {
		WindowGroup {
			RootView()
				.environmentObject(appState)   // globale Engine
		}
	}
}
