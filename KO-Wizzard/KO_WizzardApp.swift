import SwiftUI
import Foundation
import UserNotifications
import Combine

@main
struct KO_WizardApp: App {

	@StateObject private var appState = AppStateEngine()
#if DEBUG
	@AppStorage("debugThemeMode") private var debugThemeModeRaw: String = ThemeMode.system.rawValue
	@AppStorage("debugThemeOverrideEnabled") private var debugThemeOverrideEnabled: Bool = false
#endif

	init() {
			// Optional: Notifications erlauben
		UNUserNotificationCenter.current()
			.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
	}

	var body: some Scene {
#if DEBUG
		let themeMode = debugThemeOverrideEnabled
			? (ThemeMode(rawValue: debugThemeModeRaw) ?? .system)
			: .system
#else
		let themeMode = ThemeMode.system
#endif

		WindowGroup {
			RootView()
				.environmentObject(appState)   // globale Engine
				.appTheme(AppTheme(mode: themeMode))
				.preferredColorScheme(themeMode == .system ? nil : (themeMode == .dark ? .dark : .light))
		}
		.windowStyle(.hiddenTitleBar)
	}
}
